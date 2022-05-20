/*****
 * Name         : DGTL_Layout
 * Description  : This Class is used fetch contents from layout and used to create/update contents.
 * Author       : Vidya Sagar 
 * Component    : This class is controller for lightning compoenent DGTL_Layout.cmp
****/
public class DGTL_Layout {
    
     /*
      *   Description : This Method is used to get logged in user brand
      *   Return      : string, logged in user brand
      */
    @AuraEnabled
    public static string getUserBrandHpr()
    {
       return DGTL_DataAccessor.getUserBrand(); 
       //return DGTL_DataAccessor.getUserDetails();         
    }
    
     /*
      *  Description : This Method is used to data issue RecordTypeId from Tickets object
      *  Return      : Id, RecordTypeId
      */
    @AuraEnabled
    public static Id getDataIssuesRecordTypeID()
    {
        return Schema.SObjectType.DGTL_Tickets__c.getRecordTypeInfosByName().get('Data Issues').getRecordTypeId();
    }
    
    /*
     *   Description : This Method is used to get logged in user detail
     *   Return      : User, logged in user 
     */
    @AuraEnabled
    public static User getCurrentUserDetails()
    {
        return [SELECT Id,DGTL_Profile__c,DGTL_Brands__c FROM User WHERE Id  =:UserInfo.getUserId()];
    }
    
    /*
     *   Description : This Method is used to get logged in user brand
     *   Return      : User object,
     */
    @AuraEnabled
    public static user currentUserDetails()
    {
      
       return DGTL_DataAccessor.getUserDetails();         
    }

    /*
    *   Description : This Method is used to get LastModifiedBy.Name and LastModifiedDate
    *   LWC  dGTL_LastModifiedInfo  component method 
    *   Param : placementLayoutId - placement Layout Id
    *   Return : Placement Layout object record
    */
    @AuraEnabled(cacheable=true)
    public static Placement_Layout__c getLastModified(String placementLayoutId){
        Placement_Layout__c result = [SELECT Id,Name,LastModifiedById,LastModifiedBy.Name,LastModifiedDate
                                     from Placement_Layout__c WHERE ID =:placementLayoutId LIMIT 1];
        return result;
    }
    
    /*
    *   Description : This Method is used to save ticket.
    *   Param       : Ticket - ticket object
    *   Return      : String, Success/Error
    */
    @AuraEnabled
    public static String saveTicket( DGTL_Tickets__c Ticket){
        Try{
            Ticket.RecordTypeId = Schema.SObjectType.DGTL_Tickets__c.getRecordTypeInfosByName().get('Data Issues').getRecordTypeId();
            insert Ticket;
            return 'Success';
        }catch (Exception e){
            return 'Error';
        }
    }
    
    /*
    *  Description : This Method is used to Delete Contents with its Detail Records
    *  Param       : list_Contents - list of contents,contentIds - list of content ids
    *  Return      : String, Success/Error
    */
    @AuraEnabled
    public static String deleteContentsWithDetails( List<Placement_Content__c> list_Contents, List<Id> contentIds){
       List<Placement_Content_Detail__c> details = new List<Placement_Content_Detail__c>();
        Try{
            details = [SELECT ID,Name from Placement_Content_Detail__c WHERE Placement_Content__c IN: contentIds];
            if(details.size() > 0) DELETE details;
            DELETE list_Contents;
            return 'Success';
        }catch (Exception e){
            return 'Error :'+e.getMessage();
        }
    }

    /*
    *   Description             : This Method is used to get contents list from layout/library, when user clicks on search button
    *   Component helper method : fetchContentJsHpr
    *   Param                   :  layout - selected layout to search, searchNextBack - string search/PREVIOUS Update/NEXT Update, isNewLayout - boolean new/old layout,payLayoutId - Placement Layout Id
    *   Return                  : DGTL_WrapperClasses.LayoutSearchResults -- wrapper class with content,content details and layout details
    */
    @AuraEnabled
    public static DGTL_WrapperClasses.LayoutSearchResults fetchContents(Placement_Layout__c layout,String searchNextBack,boolean isNewLayout,string payLayoutId)
    {
        // variables 
        DGTL_WrapperClasses.LayoutSearchResults searchResults = new DGTL_WrapperClasses.LayoutSearchResults();
        String header = '';
        String transactionMessage = 'Action type : '+searchNextBack; //this is used to show transaction message
        List<DGTL_WrapperClasses.contentWprNew> list_ContentsWpr = new List<DGTL_WrapperClasses.contentWprNew>();
        DGTL_Floorset_Plan__c  obj_FloorSetPlan = New DGTL_Floorset_Plan__c(); 
        DGTL_Access_Management__c accessMng =  new DGTL_Access_Management__c();
        list<Placement_Layout__c> list_Layout ;
        List<Placement_Library__c> list_Library = new List<Placement_Library__c>();
        List<Placement_Content__c> list_Contents ; 
        map<id, list<Placement_Content_Detail__c>> map_CloneDetails = new map<id, list<Placement_Content_Detail__c>>();
        DGTL_Floorset_Plan__c previousFloorset; // this variable is used when layout is not found searches from previous layout new requirment 
        Map<Placement_Content__c,List<Placement_Content_Detail__c>> map_ContAndDetail ;
        //SELECT THE FLOORSET PLAN BASED ON TYPE - SEARCH , NEXT, PREVIOUS
        list<DGTL_Floorset_Plan__c> lst_FP = DGTL_DataAccessor.getFloorsetPlanList1(DGTL_DataAccessor.getSobjectSoql(obj_FloorSetPlan), layout, 'Search', null);
        if(lst_FP != null && !lst_FP.Isempty()) obj_FloorSetPlan = lst_FP[0];
        if(searchNextBack != 'Search'){
            obj_FloorSetPlan = DGTL_DataAccessor.getValidFloorset(
                DGTL_DataAccessor.getFloorsetPlanList1(DGTL_DataAccessor.getSobjectSoql(obj_FloorSetPlan),layout, searchNextBack, obj_FloorSetPlan.Date__c)
                ,searchNextBack,obj_FloorSetPlan.Date__c,obj_FloorSetPlan.Time_No__c);          
        }
        
        //Floorset plan doesnot exist
        if(obj_FloorSetPlan.Id == Null) {
            if(searchNextBack == 'Next Update'){
                DGTL_ErrorMessages__c errorMessageCustSetting = DGTL_ErrorMessages__c.getValues('DGTL_LayoutNoFloorsetPlanNext');
                searchResults.errorStatus = errorMessageCustSetting.Error_Message__c;
                searchResults.errorCode = 'DGTL_LayoutNoFloorsetPlanNext';
            }else{
                DGTL_ErrorMessages__c errorMessageCustSetting = DGTL_ErrorMessages__c.getValues('DGTL_LayoutNoFloorsetPlanPrevious');
                searchResults.errorStatus = errorMessageCustSetting.Error_Message__c;
                searchResults.errorCode = ' DGTL_LayoutNoFloorsetPlanPrevious';
            }
            /*DGTL_ErrorMessages__c errorMessageCustSetting = DGTL_ErrorMessages__c.getValues('DGTL_LayoutNoFloorsetPlan');
            searchResults.errorStatus = errorMessageCustSetting.Error_Message__c;
            searchResults.errorCode = 'DGTL_LayoutNoFloorsetPlan';*/
            return searchResults; 
        }
        
        layout.Floorset_Plan__c = obj_FloorSetPlan.id;
        searchResults.plaLayout = layout;
        system.debug(layout);
      
        Id RecordTypeId = Schema.SObjectType.DGTL_Access_Management__c.getRecordTypeInfosByName().get('Field Access').getRecordTypeId();            
        // get Access Management record for 'Placement_Content_Detail__c'
        DGTL_Access_Management__c detailAccessMng = new DGTL_Access_Management__c();
        detailAccessMng = DGTL_DataAccessor.getAccessMang(layout.Brands__c, layout.Page_Types__c, 'Placement_Content_Detail__c', 'Layout - Content Details',RecordTypeId); 
        if(detailAccessMng.Read_Only_Fields__c != null || detailAccessMng.Writable_Fields__c != null){
            // get read fields to be displayed 
            if(string.IsNotBlank(detailAccessMng.Read_Only_Fields__c)){
                searchResults.detailReadFieldsMap = DGTL_DataAccessor.getFieldLabels('Placement_Content_Detail__c', detailAccessMng.Read_Only_Fields__c.split(';'));
            }
            // get edit fields to be displayed 
            if(string.IsNotBlank(detailAccessMng.Writable_Fields__c)){
                searchResults.detailWriteFieldsMap = DGTL_DataAccessor.getFieldLabels('Placement_Content_Detail__c', detailAccessMng.Writable_Fields__c.split(';'));
            }                
        } 
        
        // get access management record for Placement_Content__c
        accessMng = DGTL_DataAccessor.getAccessMang(layout.Brands__c, layout.Page_Types__c, 'Placement_Content__c', 'DGTL Main',RecordTypeId); 
        
        if(accessMng.Read_Only_Fields__c == null && accessMng.Writable_Fields__c == null){
             // displaying error message for no access
            DGTL_ErrorMessages__c errorMessageCustSetting = DGTL_ErrorMessages__c.getValues('DGTL_Main_NoAccessMang');
            searchResults.errorStatus = errorMessageCustSetting.Error_Message__c;
            searchResults.errorCode = 'DGTL_Main_NoAccessMang';
            return searchResults;
        }
        //added by sudha
        
        if(accessMng.MiniView_RO_Fields__c !=null){
           searchResults.miniViewFieldsMap = DGTL_DataAccessor.getFieldLabels('Placement_Content__c', accessMng.MiniView_RO_Fields__c.split(';'));
            
        }
        
        // end of code (sudha)
        system.debug('--accessMng--'+accessMng.Id);
        // get buttons to be displayed                 
        if(string.IsNotBlank(accessMng.Button__c)){ //old field was --- Buttons__c
            searchResults.buttons = accessMng.Button__c;
        } 
        // get read fields to be displayed 
        if(string.IsNotBlank(accessMng.Read_Only_Fields__c)){
            searchResults.readFieldsMap = DGTL_DataAccessor.getFieldLabels('Placement_Content__c', accessMng.Read_Only_Fields__c.split(';'));
        }
        // get edit fields to be displayed 
        if(string.IsNotBlank(accessMng.Writable_Fields__c)){
            searchResults.isEditable = true;
            searchResults.editFieldsMap = DGTL_DataAccessor.getFieldLabels('Placement_Content__c', accessMng.Writable_Fields__c.split(';'));
        }
        
        list_Layout = new list<Placement_Layout__c>();
        list_Contents = new List<Placement_Content__c>();
        system.debug('---editorial isNewLayout---'+isNewLayout);
        // checks for Editorials Page Type
         if(layout.Page_Types__c == 'Editorials') {
             // checks for layout Id
             if(string.isNotBlank(payLayoutId) ){//&& searchNextBack == 'Search')// && layout.Id == null) {layout.Id = payLayoutId;}
             SYSTEM.debug('==payLayoutId--='+payLayoutId);
             list_Layout = DGTL_DataAccessor.getLayoutList(DGTL_DataAccessor.getSobjectSoql(new Placement_Layout__c()), null, 'Editorials', null, null, 'Layout', payLayoutId,null, null);
             }else{
                 string layType = 'Layout';string deviceType = layout.Device_Type__c;Id flrId = layout.Floorset_Plan__c;string laybrand = layout.Brands__c;string laypagty = layout.Page_Types__c;string editorialName = layout.Collection_Page_Name__c;
                 string editorialSoql = DGTL_DataAccessor.getSobjectSoql(new Placement_Layout__c()) + ' AND Device_Type__c =:deviceType AND Floorset_Plan__c =:flrId AND Brands__c =:laybrand  AND Page_Types__c=:laypagty AND Type__c=:layType AND Is_Deleted__c = false AND Collection_Page_Name__c =:editorialName';
                 list_Layout = Database.query(editorialSoql);
                 // Fetching from Previous Layout
                 if(list_Layout.size() == 0){
                        previousFloorset = DGTL_DataAccessor.getValidFloorset(
                                                            DGTL_DataAccessor.getFloorsetPlanList1(DGTL_DataAccessor.getSobjectSoql(obj_FloorSetPlan),layout, 'Previous Update', obj_FloorSetPlan.Date__c)
                                                                ,'Previous Update',obj_FloorSetPlan.Date__c,obj_FloorSetPlan.Time_No__c); 
                        system.debug('--previousFloorset--'+previousFloorset);
                        if(previousFloorset != null){
                            flrId = previousFloorset.Id;
                            editorialSoql = DGTL_DataAccessor.getSobjectSoql(new Placement_Layout__c()) + ' AND Device_Type__c =:deviceType AND Floorset_Plan__c =:flrId AND Brands__c =:laybrand  AND Page_Types__c=:laypagty AND Type__c=:layType AND Is_Deleted__c = false AND Collection_Page_Name__c =:editorialName';
                            list_Layout = Database.query(editorialSoql);
                            if(list_Layout.size() != 0)
                            searchResults.isPreviousLayout = true;
                        }
                 }
                 //list_Layout = DGTL_DataAccessor.getLayoutList(DGTL_DataAccessor.getSobjectSoql(new Placement_Layout__c()), layout.Brands__c, layout.Page_Types__c, null, null, 'Layout', null,layout.Device_Type__c, layout.Floorset_Plan__c);
             }
             /*if(searchNextBack != 'Search'){
                 list_Layout = DGTL_DataAccessor.getLayoutList(DGTL_DataAccessor.getSobjectSoql(new Placement_Layout__c()), layout.Brands__c, layout.Page_Types__c, null, null, 'Layout', null,layout.Device_Type__c, layout.Floorset_Plan__c);
                 for()
             }*/
        }else{
            list_Layout = DGTL_DataAccessor.getLayoutList(DGTL_DataAccessor.getSobjectSoql(new Placement_Layout__c()), layout.Brands__c, layout.Page_Types__c, null, null, 'Layout', null,layout.Device_Type__c, layout.Floorset_Plan__c);
            // if layout does not exists searches from prevoious layout
                if(list_Layout.size() == 0){
                    try{
                        
                        previousFloorset = DGTL_DataAccessor.getValidFloorset(
                                                            DGTL_DataAccessor.getFloorsetPlanList1(DGTL_DataAccessor.getSobjectSoql(obj_FloorSetPlan),layout, 'Previous Update', obj_FloorSetPlan.Date__c)
                                                                ,'Previous Update',obj_FloorSetPlan.Date__c,obj_FloorSetPlan.Time_No__c); 
                    
                    }catch(Exception e){}
                    
                    if(previousFloorset != null)
                      list_Layout = DGTL_DataAccessor.getLayoutList(DGTL_DataAccessor.getSobjectSoql(new Placement_Layout__c()), layout.Brands__c, layout.Page_Types__c, null, null, 'Layout', null,layout.Device_Type__c, previousFloorset.Id);  
                     if(list_Layout.size() != 0)
                      searchResults.isPreviousLayout = true;
                   
                    
                }
        }
            
        
        system.debug('--list_Layout--'+list_Layout); 
        system.debug('--searchResults.isPreviousLayout--'+searchResults.isPreviousLayout); 
        //FETCH FROM CONTENTS
        if(list_Layout.size() > 0){
            if(!searchResults.isPreviousLayout && list_Layout[0].Compared_Placement_Layout__c != null){
                String name = [SELECT Name FROM Placement_Layout__c WHERE Id=:list_Layout[0].Compared_Placement_Layout__c LIMIT 1].Name;
                transactionMessage += '<br/> Compared With : ' + name;
                header += 'LOCKED';
            }
            header += searchResults.isPreviousLayout ? '<br/> Contents from Previous Layout.' :  '<br/> Contents from Layout.';
            if(searchResults.isPreviousLayout){
               searchResults.plaLayout = list_Layout[0].clone(); 
               searchResults.plaLayout.Compared_Placement_Layout__c = null;
               searchResults.plaLayout.Floorset_Plan__c = layout.Floorset_Plan__c;
               searchResults.plaLayout.OwnerId = null;
            }else{
                searchResults.plaLayout = list_Layout[0];
                searchResults.pLayoutId = string.valueOf(list_Layout[0].Id);
            }
              
           // layout = list_Layout[0];
             layout = searchResults.plaLayout;
             if(!searchResults.isPreviousLayout){
                 // getting list of contents from layout
                list_Contents = DGTL_DataAccessor.getContentList(DGTL_DataAccessor.getSobjectSoql(new Placement_Content__c()), layout.Id, 'Type__c ,S_No__c', null,null,'',false);
             }else{
                  map_ContAndDetail = new Map<Placement_Content__c,List<Placement_Content_Detail__c>>();
                  // cloning contents from Previous layout
                  map_ContAndDetail = DGTL_DataAccessor.getPreviousLayoutContents(list_Layout[0].Id);
                  list_Contents.addAll(map_ContAndDetail.keySet());
                  system.debug('---map_ContAndDetail--'+map_ContAndDetail.values());
             }
            
            system.debug('--list_Contents--'+list_Contents.size());
        }
        
        //FETCH FROM LIBRARY
        if(((list_Layout.size() == 0 && layout.Page_Types__c != 'Editorials') || isNewLayout) && accessMng.Button__c.contains('Create - Layout') && !searchResults.isPreviousLayout) { //&& accessMng.Button__c.contains('Create - Layout')
            header += '<br/> Contents from Library.';
            //Clear the existing Id 
            searchResults.plaLayout.id = null; 
            searchResults.isPreviousLayout = false;
            id id_lib ;
            //list_Library = DGTL_DataAccessor.getLibraryList(DGTL_DataAccessor.getSobjectSoql(new Placement_Library__c()), layout.Brands__c, layout.Page_Types__c, obj_FloorSetPlan.Date__c, 'Position__c', null,null,''); //--- page type is editorial
            if(layout.Page_Types__c == 'Editorials'){ // get editorials by search text
               list<Placement_Library__c> List_tempLib = new list<Placement_Library__c>(); date dateVar = obj_FloorSetPlan.Date__c;
               String libraryQuery = DGTL_DataAccessor.getSobjectSoql(new Placement_Library__c());
               libraryQuery += ' AND Brands__c =\''+layout.Brands__c+'\' AND Page_Types__c =\''+layout.Page_Types__c+'\''  ;                                                   
               libraryQuery += ' AND End_Date__c >=: dateVar AND Start_Date__c <=:dateVar ';
               libraryQuery += ' AND Editorial_Name__c like \'%'+layout.Collection_Page_Name__c+'%\' Order by Position__c';
               List_tempLib = Database.query(libraryQuery); system.debug('libraryQuery--'+libraryQuery);
               list_Library = DGTL_DataAccessor.getValidLibraryList(List_tempLib,obj_FloorSetPlan.Date__c,obj_FloorSetPlan.Time_No__c);
            } else{
                list_Library = DGTL_DataAccessor.getValidLibraryList(DGTL_DataAccessor.getLibraryList(DGTL_DataAccessor.getSobjectSoql(new Placement_Library__c()), layout.Brands__c, layout.Page_Types__c, obj_FloorSetPlan.Date__c, 'Position__c', null,null,''),obj_FloorSetPlan.Date__c,obj_FloorSetPlan.Time_No__c);
            }
            system.debug('--list_Library--'+list_Library);
            string contDetail_soql = DGTL_DataAccessor.getSobjectSoql( new Placement_Content_Detail__c());  
            contDetail_soql +=  ' AND Placement_Library__c In : list_Library';
            // cloning content details from Library
            for(Placement_Content_Detail__c details : Database.query(contDetail_soql)){system.debug('in' + details);
                Placement_Content_Detail__c newDetail = new Placement_Content_Detail__c();
                newDetail = details.clone(false, false, false, false);
                id_lib = newDetail.Placement_Library__c;
                if(map_CloneDetails.get(id_lib) == null) map_CloneDetails.put(id_lib, new list<Placement_Content_Detail__c>());
                map_CloneDetails.get(id_lib).add(newDetail);
            }
            list_Contents = DGTL_DataAccessor.createContentsFromLibrary(list_Library, DGTL_DataAccessor.getLibraryCopyFieldset());
        }system.debug(map_CloneDetails);
        DGTL_WrapperClasses.contentWprNew cWpr;
        DGTL_WrapperClasses.ContentDetailWrp detWrp;
        Set<Id> contentIds;
        Map<Id,List<DGTL_WrapperClasses.KODDetail>> kodDetailMap;
        
        //collect content id set
        if(list_Contents != null && list_Contents.size() > 0){
            contentIds = new Set<Id>();
            kodDetailMap = new Map<Id,List<DGTL_WrapperClasses.KODDetail>>();
            for(Placement_Content__c pCnt : list_Contents){
                try{
                    if(pCnt.Id != null){
                        contentIds.add(pCnt.Id);
                    }
                }catch(Exception e){
                    System.debug(e.getMessage());
                }
            }
            // FETCH Placement KODs
            if(contentIds.size() > 0){
                for(Placement_KOD__c pKod : [SELECT Placement_Content__c,KOD__r.Name, KOD__c FROM Placement_KOD__c WHERE Placement_Content__c IN:contentIds]){
                    DGTL_WrapperClasses.KODDetail kodDetail = new DGTL_WrapperClasses.KODDetail();
                    kodDetail.id = pKod.KOD__c; 
                    kodDetail.name = pkod.KOD__r.Name;
                    if(!kodDetailMap.containsKey(pKod.Placement_Content__c)) {kodDetailMap.put(pKod.Placement_Content__c,new List<DGTL_WrapperClasses.KODDetail>());}
                    kodDetailMap.get(pKod.Placement_Content__c).add(kodDetail);
                }
            }
        }
        
        // assigning list of contents to wrapper class
        for(Placement_Content__c pCnt : list_Contents)
        {                   
            cWpr = new DGTL_WrapperClasses.contentWprNew();
            detWrp = new DGTL_WrapperClasses.ContentDetailWrp();
            cWpr.pContentRec = pCnt; 
            // checks for cloned content from previous layout
            if(searchResults.isPreviousLayout){
                cWpr.clonedContId = pCnt.getCloneSourceId();
                system.debug('--clonedContId--'+cWpr.clonedContId);
                detWrp.detailList =  map_ContAndDetail.get(pCnt);
            } 
            
            // Check Access management button values
            accessMng.Button__c = String.isNotBlank(accessMng.Button__c) ? accessMng.Button__c : '';
            if(pCnt.Active__c && accessMng.Button__c.contains('Delete - Content') && pCnt.Compared_Placement_Layout__c ==null)
                cWpr.removeBtn = true;           
            if(pCnt.Id != null){ 
                // buttons 
                if(pCnt.Active__c && pCnt.Type__c != 'Escalation' && pCnt.Placement_Library__c!=null && accessMng.Button__c.contains('Cascade'))
                cWpr.cascade = true;
                if(pCnt.Active__c && accessMng.Button__c.contains('Comment - Content'))
                cWpr.commentBtn = true;
                if(accessMng.Button__c.contains('History - Content'))
                cWpr.historyBtn = true;
                if(accessMng.Button__c.contains('Update Content') && pCnt.Compared_Placement_Layout__c != null)
                cWpr.updateContent = true;
                //to show task picklist
                if(accessMng.Button__c.contains('Create - Tickets'))
                cWpr.createTicketBtn =true;

                // check with boopathi Compared_Placement_Layout__c = null is in mini view and not in full view
                if(pCnt.Active__c && pCnt.Type__c == 'Controlled' && accessMng.Button__c.contains('Create AB Test')){
                   cWpr.abTestBtn = true;
                   cWpr.ContentTypesList.add('AB Test');
                }                
                // check with boopathi Compared_Placement_Layout__c = null is in mini view and not in full view
                if(pCnt.Active__c && pCnt.Type__c == 'Controlled' && accessMng.Button__c.contains('Create Takedown') && layout.Page_Types__c !='Editorials'){
                  cWpr.TakedownBtns = true;
                  cWpr.ContentTypesList.add('Takedown');
                }
                // check for Contigency 
                 if(pCnt.Active__c && pCnt.Type__c == 'Controlled' && accessMng.Button__c.contains('Create Contingency') && layout.Page_Types__c !='Editorials'){
                      cWpr.ContentTypesList.add('Contingency');
                   }
                 if(!cWpr.ContentTypesList.isEmpty())
                        cWpr.enableContentTypePrompt = true;
                 if(pCnt.Type__c == 'AB Test' || pCnt.Type__c == 'Takedown' || pCnt.Type__c == 'Contingency'){
                        if(searchResults.ContentTypesBtns.containskey(pCnt.Type__c))
                        searchResults.ContentTypesBtns.put(pCnt.Type__c,searchResults.ContentTypesBtns.get(pCnt.Type__c)+1);
                        else
                        searchResults.ContentTypesBtns.put(pCnt.Type__c,1);
                    }
                if(pCnt.Active__c && accessMng.Button__c.contains('Add KOD') && pCnt.Offer_Type__c == 'Offer')
                cWpr.addKOD = true;
                // adding kodDetails
                if(kodDetailMap.containsKey(pCnt.Id)) cWpr.kodList = kodDetailMap.get(pCnt.Id);
                
                cWpr.conId = pCnt.Id;
                //  adding list of read and write fields for content detail  
                cWpr.detailAllFeildList = new List<String>();
                
                // adding list of content detail  
                detWrp.detailList =  pCnt.Placement_Content_Details__r;
                detWrp.detailDeleteList = new list<Placement_Content_Detail__c>();
                if(pCnt.Content_Type__c == 'Carousel'){
                    detWrp.isCarousel = true;
                }                
            }else{
                cWpr.conId = DGTL_DataAccessor.generateRandomString(18); 
              
                if(map_CloneDetails.size() > 0 && (list_Layout.size() == 0 || isNewLayout)) {                                                                               
                    if(pCnt.Placement_Library__c != null &&  map_CloneDetails.get(pCnt.Placement_Library__c) != null) 
                        detWrp.detailList = map_CloneDetails.get(pCnt.Placement_Library__c);                                                                                             
                }
            }
            // assign the detail wrapper to Content wrapper
            cWpr.ContentDetWpr = detWrp;  SYSTEM.DEBUG(cWpr.ContentDetWpr );
            searchResults.hasContents = true;
            searchResults.list_contentWpr.add(cWpr);                    
        }
        
        // displaying error message for no contents
        if(list_Contents.isEmpty()){
            if(searchNextBack == 'Next Update'){
               DGTL_ErrorMessages__c errorMessageCustSetting = DGTL_ErrorMessages__c.getValues('DGTL_LayoutNoPlaceContsNext');
               searchResults.errorCode = 'DGTL_LayoutNoPlaceContsNext';
               searchResults.errorStatus = errorMessageCustSetting.Error_Message__c; 
            }else if(searchNextBack == 'Search'){
                DGTL_ErrorMessages__c errorMessageCustSetting = DGTL_ErrorMessages__c.getValues('DGTL_Main_NoPlaceConts');
                searchResults.errorCode = 'DGTL_Main_NoPlaceConts';
                searchResults.errorStatus = errorMessageCustSetting.Error_Message__c;
            }else{
                DGTL_ErrorMessages__c errorMessageCustSetting = DGTL_ErrorMessages__c.getValues('DGTL_LayoutNoPlaceContsPrevious');
                searchResults.errorCode = 'DGTL_LayoutNoPlaceContsPrevious';
                searchResults.errorStatus = errorMessageCustSetting.Error_Message__c;
            }
           /* DGTL_ErrorMessages__c errorMessageCustSetting = DGTL_ErrorMessages__c.getValues('DGTL_Main_NoPlaceConts');
            searchResults.errorCode = 'DGTL_Main_NoPlaceConts';
            searchResults.errorStatus = errorMessageCustSetting.Error_Message__c;*/
            return searchResults; 
        }
        searchResults.transactionMessageMap.put('message',transactionMessage);
        searchResults.transactionMessageMap.put('header',header);
        return searchResults;
    }
        
    /*
    *   Description             : This Method is used to create/update library and contents, when user clicks on final save/submit button
    *   Component helper method : updateContentJsHpr
    *   Param                   : pLayout - Placement Layout,payLayoutId - Placement Layout Id,list_ContentToUpdate - list of contents,list_RemovedContent - list of removed/inactive contents,isPreviousLayout - Boolean is previous layout
    *   Return                  : String, Success/Error Message
    */
    @AuraEnabled
    public static String finalSubmitContent(Placement_Layout__c pLayout,String payLayoutId,List<DGTL_WrapperClasses.contentWprNew> list_ContentToUpdate,List<Placement_Content__c> list_RemovedContent,boolean isPreviousLayout)
    {
        Savepoint sp = Database.setSavepoint();        
        try{
            
            // variables
            boolean isNewLayout = false;
            List<Placement_Content__c> list_DeleteContent = new List<Placement_Content__c>(); // used to store Deleted contents on update  
            List<Placement_Content__c> list_UpsertContent = new List<Placement_Content__c>(); // used to create/update contents          
            List<Placement_Content_Detail__c> list_FilteredUpsertDetail = new List<Placement_Content_Detail__c>(); // used to create/update contents
            List<Placement_Content_Detail__c> list_UpsertDetail = new List<Placement_Content_Detail__c>(); // used to create/update contents
            List<Placement_Content_Detail__c> list_DeleteDetail = new List<Placement_Content_Detail__c>(); // used to create/update contents
            map<string,Placement_Content__c> map_ClonedIdCont = new map<string,Placement_Content__c>(); // used when searched from previous layout
            Integer i = 1; // used for ordering s no for contents
            // checks for existing layout and if does not creates new layout 
            if(String.IsBlank(payLayoutId))
            { 
                pLayout.Type__c = 'Layout' ;                       
                insert pLayout ;
                isNewLayout = true;
                payLayoutId = pLayout.Id;
            }  else{
                system.debug('--pLayout--'+pLayout.Collection_Page_Url__c);
                if(pLayout != null && pLayout.Id != null) update pLayout; //-------------- update Placement Layout On every Save 
            }    
            
            if(String.IsNotBlank(payLayoutId))
            { 
                for(DGTL_WrapperClasses.contentWprNew cWpr : list_ContentToUpdate)
                {
                    Placement_Content__c pcm = cWpr.pContentRec;
                    // checks for previous layout
                    if(isPreviousLayout){
                        map_ClonedIdCont.put(cWpr.clonedContId,pcm);
                    }
                    if((isNewLayout && pcm.Active__c) || !isNewLayout ) {
                       // if(pLayout.Page_Types__c != 'Editorials')
                       pcm.S_No__c = i;
                        
                        system.debug(pcm.Id);             
                        if(pcm.Id == Null) {
                            pcm.Active__c = true; 
                            pcm.Placement_Layout__c = payLayoutId;
                        } 
                         DGTL_WrapperClasses.ContentDetailWrp contDetail = cWpr.ContentDetWpr;
                        //Add placement for hard delete if layout not locked and inactive
                        if(pcm.Compared_Placement_Layout__c == null && !pcm.Active__c && !isNewLayout ) {
                            list_DeleteContent.add(pcm);  //List to delete placemnts
                            list_DeleteDetail.addAll(contDetail.detailDeleteList);  
                            for(Placement_Content_Detail__c eachDetail : contDetail.detailList) {
                                if(eachDetail.Id != null) list_DeleteDetail.add(eachDetail); 
                            } 
                        }
                        else {
                            list_UpsertContent.add(pcm);system.debug(pcm);                           
                            list_DeleteDetail.addAll(contDetail.detailDeleteList);  
                            list_UpsertDetail.addAll(contDetail.detailList);                                       
                        }
                          
                        i++; 
                    }
                }
            }       
            /*
            if(!list_RemovedContent.isEmpty())
            {  for(Placement_Content__c plc : list_RemovedContent)
                {  // checks for new/not saved content
                    if(plc.Id != Null)
                    {   plc.Active__c = false;
                        list_UpsertContent.add(plc);
                    }
                }
            }system.debug(list_RemovedContent);*/            system.debug(list_DeleteContent);
            
            map<id,id> map_ConLib = new map<id,id>();
            if(!list_UpsertContent.isEmpty()) {
                Upsert list_UpsertContent;
                
                for(Placement_Content__c plc : list_UpsertContent){
                    map_ConLib.put(plc.Placement_Library__c, plc.Id);
                }
            }
			if(isPreviousLayout && !list_UpsertContent.isEmpty()){
				// this method is used to update parent content id for AB Test/Takedown/Contingency contents
					updateParentContentIds(list_UpsertContent,map_ClonedIdCont);
			     // this method is used to clone KODs
					insertClonedKODS(map_ClonedIdCont.keySet(),map_ClonedIdCont);
			}
            if(!list_UpsertDetail.isEmpty()){
                for(Placement_Content_Detail__c detRec : list_UpsertDetail){
                    if(String.isNotBlank(detRec.Sub_Type__c) ||  String.isNotBlank(detRec.Copy__c) 
                            ||  String.isNotBlank(detRec.Asset_Path__c) ||  String.isNotBlank(detRec.Link_Text__c) 
                       ||  String.isNotBlank(detRec.Slides__c) || String.isNotBlank(detRec.Comments__c)){
                             list_FilteredUpsertDetail.add(detRec);
                       }else if(detRec.Id != null){
                           // delete if all are blank
                           list_DeleteDetail.add(detRec);
                       }
                    if(!isPreviousLayout && detRec.Placement_Content__c == null) {
                        detRec.Placement_Content__c = map_ConLib.get(detRec.Placement_Library__c);
                        detRec.Placement_Library__c = null;
                    }else if(isPreviousLayout){
                        //string contId = string.valueof(detRec.Placement_Content__c);
                       // system.debug('-detail contid--'+contId);
                        if(map_ClonedIdCont.containsKey(detRec.Placement_Content__c))
						detRec.Placement_Content__c = map_ClonedIdCont.get(detRec.Placement_Content__c).Id;
                        detRec.Placement_Library__c = null;
					}
						
                }
            }
            
            if(!list_FilteredUpsertDetail.isEmpty()){
                Upsert list_FilteredUpsertDetail;
            }
            if(!list_DeleteDetail.isEmpty()){
                Delete list_DeleteDetail;
            }
            if(!list_DeleteContent.isEmpty()){
                Delete list_DeleteContent;
            }
            
            return 'Success,'+payLayoutId;
        }
        catch(exception e){
            system.debug('--exception final submit--'+e.getMessage()+'--'+e.getLineNumber());
            Database.rollback(sp);
            if(string.valueOf(e).contains('DUPLICATE_VALUE'))                
            return DGTL_ErrorMessages__c.getValues('DGTL_DuplicateLayoutorContent').Error_Message__c;
            return e.getMessage();
        }
    }
    
    /*
    *   Description             : This Method is used to search other contents from other layout with selected brand,pageType,floorset plan Id 
    *   Component helper method : searchContentToAddHpr
    *   Param                   : pageLayoutForAdd - Placement_Layout__c, editorialId - Editorial layout id 
    *   Return                  : list of DGTL_WrapperClasses.contentWprNew
    */
    @AuraEnabled 
    public static List<DGTL_WrapperClasses.contentWprNew> searchSelectedContFromExistingLayout(Placement_Layout__c pageLayoutForAdd,string editorialId)
    { 
        try {
            List<DGTL_WrapperClasses.contentWprNew> list_ContentsWpr = new List<DGTL_WrapperClasses.contentWprNew>();
            List<Placement_Content__c> list_Contents = new List<Placement_Content__c>();
            // checks for Editorials
            if(string.isNotBlank(editorialId)){
                    list_Contents = DGTL_DataAccessor.getContentList(DGTL_DataAccessor.getSobjectSoql(new Placement_Content__c()), editorialId, 'Type__c, S_No__c', null,null,'',true);
            }else{
               list<Placement_Layout__c>  lst_Layouts = DGTL_DataAccessor.getLayoutList(DGTL_DataAccessor.getSobjectSoql(new Placement_Layout__c()), null, pageLayoutForAdd.Page_Types__c, null, null, 'Layout', null,pageLayoutForAdd.Device_Type__c,pageLayoutForAdd.Floorset_Plan__c);
                // fetch contents 
                if(lst_Layouts != null && lst_Layouts.size() > 0){
                    list_Contents = DGTL_DataAccessor.getContentList(DGTL_DataAccessor.getSobjectSoql(new Placement_Content__c()), lst_Layouts[0].id, 'Type__c, S_No__c', null,null,'',true);
                }
            }
                if(list_Contents.size() > 0){
                    // mapping contents with wrapper class
                    for(Placement_Content__c pCnt : list_Contents)
                    {    
                        DGTL_WrapperClasses.contentWprNew cWpr = new DGTL_WrapperClasses.contentWprNew();
                        pCnt.Has_Unapproved__c = false;
                        //pCnt.Parent_Content__c = null;
                        cWpr.pContentRec = pCnt;
                        cWpr.conId = pCnt.Id;
                        
                        list_ContentsWpr.add(cWpr);                    
                    }
                }              
            
            return list_ContentsWpr;
        }
        catch(exception ex){
            return null;
        } 
    }
    
    /*
    *   Description : This Method is used to clone selected contents and content details from existing layout
    *   Component helper method : addSelectedContentHpr
    *   Param       : list_PlcContentToClone - list of placement contents, pLayoutId - Placement_Layout__c Id,contentType - type of content(AB Test/Takedown/Contingency),testName - string ab test name,fromExistingLayout - boolean, checks contents are form previous layout
    *   Return      : list DGTL_WrapperClasses.contentWprNew
    */
    @AuraEnabled
    public static list<DGTL_WrapperClasses.contentWprNew> saveSelectedContFromExistingLayout(List<Placement_Content__c> list_PlcContentToClone,string pLayoutId, string contentType, string testName,boolean fromExistingLayout)
    {
        list<DGTL_WrapperClasses.contentWprNew> list_cWpr = new list<DGTL_WrapperClasses.contentWprNew>();
        map<Id,Placement_Content__c> map_ContId_NewCont = new map<Id,Placement_Content__c>();
        list<Placement_Content_Detail__c> list_ContDetail = new list<Placement_Content_Detail__c>();
        DGTL_WrapperClasses.contentWprNew cWpr = new DGTL_WrapperClasses.contentWprNew();
        map<string,Placement_Content__c> map_ClonedIdCont = new map<string,Placement_Content__c>(); // used to update parent content 
        Savepoint sp = Database.setSavepoint();
        try
        {

            // Creating the Cloned Placement Content from the selected Contents
            list<Id> list_ContId = new list<Id>();
            for(Placement_Content__c pCon : list_PlcContentToClone)
            {
                Placement_Content__c newCont = new Placement_Content__c();
                // cloning content 
                newCont = pCon.clone(); 
                newCont.Compare_Type__c = '';
                map_ClonedIdCont.put(string.valueOf(newCont.getCloneSourceId()),newCont);
                // checks if method is not called from layout add from existing layout 
                if(!fromExistingLayout){
                    if(contentType != null) newCont.Type__c = contentType;
                    newCont.Parent_Content__c = (contentType == 'Takedown'  || contentType == 'AB Test' || contentType == 'Contingency') ? pCon.Id : null;
                    newCont.AB_Test_Name__c = contentType == 'AB Test' ? testName  : ''; 
                }
                
                newCont.Placement_Layout__c = pLayoutId;
                list_ContId.add(pCon.Id);
                map_ContId_NewCont.put(pCon.Id, newCont);                
                
                //Add the contents to push it to the current layouts list
                
                cWpr.pContentRec = pCon;
                cWpr.conId = pCon.Id; 
                cWpr.errorStatus = 'Success';
                list_cWpr.add(cWpr);
            }
            
            //DML -- Inserting Cloned Placement Content
            insert map_ContId_NewCont.values(); 
            // this method is used to update parent content id for AB Test/Takedown/Contingency contents
            if(fromExistingLayout)
			updateParentContentIds(map_ContId_NewCont.values(),map_ClonedIdCont);
            //Fetch the Content Details           
            string contDetail_soql = DGTL_DataAccessor.getSobjectSoql(new Placement_Content_Detail__c());
            contDetail_soql += ' and Placement_Content__c In : list_ContId';
            //Clone the Details
            for(Placement_Content_Detail__c detail : Database.query(contDetail_soql)){
                Placement_Content_Detail__c cloneDetail = detail.clone();
                cloneDetail.Placement_Content__c = map_ContId_NewCont.get(detail.Placement_Content__c).Id;
                cloneDetail.Placement_Library__c = null;
                cloneDetail.Placement_Content_Detail_Self__c = null;
                list_ContDetail.add(cloneDetail);
            }
            if(list_ContDetail.size() > 0) insert list_ContDetail;            
            return list_cWpr;
        }
        catch(exception e)
        {
            cWpr.errorStatus = e.getMessage();
            list_cWpr.add(cWpr);
            system.debug('Error in creating placement ' + e.getMessage());
            Database.rollback(sp);
            return list_cWpr;
        }
    }
    
    /*
    *   Description : This Method is used to clone selected contents and if layout does not exists then it creates new layout
    *   Component helper method : saveCloneHpr
    *   Param       : pLayout - Placement_Layout__c,list_PlcContentToClone - list of Placement_Content__c
    *   Return      : String - Success/Error
    */
    @AuraEnabled
    public static String cloneSave(Placement_Layout__c pLayout, List<Placement_Content__c> list_PlcContentToClone)
    {
        Savepoint sp = Database.setSavepoint();
        try
        {
            Id checkLayoutId ; 
            list<Placement_Layout__c> list_Layout = new list<Placement_Layout__c>();
            list_Layout = DGTL_DataAccessor.getLayoutList(DGTL_DataAccessor.getSobjectSoql(new Placement_Layout__c()), pLayout.Brands__c, pLayout.Page_Types__c, null, null, 'Layout', null,pLayout.Device_Type__c,pLayout.Floorset_Plan__c);
            if(list_Layout.size() > 0 ) checkLayoutId = list_Layout[0].Id;

            list<Placement_Content__c> lst_Con = Database.query(DGTL_DataAccessor.getSobjectSoql(new Placement_Content__c())+ ' and  id in: list_PlcContentToClone');
            // if layout does not exists create new layout            
            if(checkLayoutId == null) 
            { 
                pLayout.Type__c = 'Layout';
                insert pLayout ;
                checkLayoutId = pLayout.Id;
            }
            // cloning selected contents and adding into new content list 
            map<string, list<string>> map_ChildsToClone = new map<string, list<string>>();
            map_ChildsToClone.put('Placement_Content__c', new list<string>{'Placement_Content_Detail__c'});
            map<string, map<string, string>> map_StaticValues = new map<string, map<string, string>>();
            map_StaticValues.put('Placement_Content__c', new map<string, string>{'Placement_Layout__c' => checkLayoutId});
            DGTL_GenericMultiLevelClone.deepCloneBatched(lst_Con, 
                                                        map_ChildsToClone, 
                                                        map_StaticValues ); 
            return 'Success';
        }
        catch(exception e)
        {
            Database.rollback(sp);
            if(String.valueOf(e).Contains('DUPLICATE_VALUE'))
            {
                return 'Placement Layout already exist with this combination..!!';
            }
            else
            {
                return 'Error: '+String.valueOf(e)+' At: '+e.getStackTraceString();
            }
        }
    }    
    
       
    /**
    * @description  Disable the Placement Layout
    * @author       Boopathirajappan Nagarajan
    * @date         13 Aug 2019
    * @param        layout - Layout instance
    */
    @AuraEnabled
    public static string disablePlacementLayout(Placement_Layout__c  layout) {
        system.debug(layout);
        if(layout == null || (layout !=null && layout.id == null)) return null;
        try {
            //Placement_Layout__c ins_Layout = new Placement_Layout__c(id=layout.id, Is_Deleted__c = true);
            //update ins_Layout;
            if(layout.Id != null) delete layout;
            return 'SUCCESS';
        }
        catch(Exception e) {
            system.debug('Error Deleting the layout' + e.getMessage());
            return DGTL_ErrorMessages__c.getValues('DGTL_NotAbleToDeleteLayout').Error_Message__c;
        }        
    }
    
    /*
    *   Description : This Method is used to get editorials layouts
    *   Component helper method : fetchContentJsHpr
    *   Param       : selectedBrand - selected brand,pageType - selected page type,floorsetId - selected floorest id,deviceType - selected deviceType
    *   Return      : Map
    */
    @AuraEnabled
    public static Map<String, String> fetchEditorialLayouts(String selectedBrand,String pageType,string floorsetId,string deviceType)
    {
        return DGTL_LayoutisEditorials.fetchEditorialLayouts(selectedBrand,pageType,floorsetId,deviceType);
        
    }
    
    /*
    *   Description             : This Method is used to Layout details
    *   Param                   : layoutId - Placement_Layout__c id
    *   Return                  : Placement_Layout__c
    */
     @AuraEnabled
    public static Placement_Layout__c getLayoutInfo(String layoutId)
    {   System.debug('layoutId.....'+layoutId);
        
        Placement_Layout__c placementLayout = [SELECT Id,Name,Brands__c,Page_Types__c,Device_Type__c,Floorset_Plan__c from Placement_Layout__c
                                              Where Id =:layoutId LIMIT 1];
        return placementLayout;
        
    }
    
    /*
    *   Description             : This Method is used to get Digital live users
    *   Component helper method : DigitalLiveUsersJsHpr
    *   Param                   : layoutId - Placement_Layout__c id
    *   Return                  : list of String with user names
    */
     @AuraEnabled
    public static list<string> digitalLiveUsers(String layoutId)
    {   
        list<string> list_LiveUsersName = new list<string>();
        // fetching live users related to Placement_Layout__c
        for(Digital_Live_Users__c dgtlUser : [select id,Name,User__c,User__r.Name,Layout__c,Last_Poll_Time__c,Tab_Name__c from Digital_Live_Users__c where Layout__c=:layoutId and Tab_Name__c='DGTL Main']){
            if(!list_LiveUsersName.contains(dgtlUser.User__r.Name))
            list_LiveUsersName.add(dgtlUser.User__r.Name);
            system.debug('---dgtlUser--'+dgtlUser);
        }
        // creating new live user
        if(!list_LiveUsersName.contains(UserInfo.getName())){
            Digital_Live_Users__c liveUser = new Digital_Live_Users__c(Tab_Name__c='DGTL Main',Layout__c=layoutId,User__c=UserInfo.getUserId(),Last_Poll_Time__c=system.now());
            insert liveUser;
            system.debug('---liveUser--'+liveUser);
            list_LiveUsersName.add(UserInfo.getName());
        }
        system.debug('---list_LiveUsersName--'+list_LiveUsersName);
        return list_LiveUsersName;
        
    }
    
    /*
    *   Description : This Method is used to delete Digital live users
    *   Component helper method : deleteLiveUsersJsHpr
    *   Param       : layoutId - Placement_Layout__c id,
    */
     @AuraEnabled
    public static void deleteLiveUsers(String layoutId)
    {   
        list<Digital_Live_Users__c> list_LiveUsers = new list<Digital_Live_Users__c>();
        for(Digital_Live_Users__c livusr : [select id from Digital_Live_Users__c where Layout__c=:layoutId and Tab_Name__c='DGTL Main' and User__c=:UserInfo.getUserId()]){
            list_LiveUsers.add(livusr);
        }
        if(!list_LiveUsers.isEmpty()){
            delete list_LiveUsers;
        }
        
    }
	
	/*
	 *   @description : This Method is used to update parent content for dependent contents(AB Test/Takedown/Contingency)
	 *   @Param		  : lst_Con - List of Placement contents,map_ParentContent - Map of cloned Id and placement content
	 */
    public static void updateParentContentIds(list<Placement_Content__c> lst_Con,map<String,Placement_Content__c> map_ParentContent)
    {   
        list<Placement_Content__c> list_dependentContents = new list<Placement_Content__c>(); // this list is used to update parent content for AB Test,Takedown and Contingency 
				for(Placement_Content__c plc : lst_Con){
				    // check for content type 
					if((plc.Type__c == 'Takedown'  || plc.Type__c == 'AB Test' || plc.Type__c == 'Contingency') && map_ParentContent.get(plc.Parent_Content__c) != null){
						// updating parent content 
						plc.Parent_Content__c = map_ParentContent.get(string.valueof(plc.Parent_Content__c)).Id;
						list_dependentContents.add(plc);
					}					  
				}
				if(!list_dependentContents.isEmpty())
				  Update list_dependentContents;
        
    }
	
	/*
	 *   @description : This Method is clone KODs and insert 
	 *   @Param		  : set_ContIds - List of Placement contents,map_ParentContent - Map of cloned Id and placement content
	 */
    public static void insertClonedKODS(set<string> set_ContIds,map<String,Placement_Content__c> map_ParentContent)
    {   
        list<Placement_KOD__c> list_KODs = new list<Placement_KOD__c>(); 
            // Fetch Placement_KOD__c
			for(Placement_KOD__c pKod : [SELECT Placement_Content__c,KOD__r.Name, KOD__c FROM Placement_KOD__c WHERE Placement_Content__c IN:set_ContIds]){
				// cloning Placement_KOD__c
				Placement_KOD__c cloneKOD = pKod.clone();
				cloneKOD.Placement_Content__c = map_ParentContent.get(string.valueof(pKod.Placement_Content__c)).Id;
				list_KODs.add(cloneKOD);
			}
			// creating Placement_KOD__c list
			if(!list_KODs.isEmpty())
			   Insert list_KODs;
        
    }
}