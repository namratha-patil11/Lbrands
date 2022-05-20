/*****
 * Name         : DGTL_CloneLayoutContent
 * Description  : This Class is used to clone contents and to add to other layouts 
 * Author       : Vidya Sagar 
 * Component    : This class is controller for lightning compoenent DGTL_CloneLayoutContent.cmp
****/
public class DGTL_CloneLayoutContent {
    
    /*
    *   Description : This Method is used to get list of layouts
    *   Param       : placLayout - Placement_Layout__c, startdate - start date, enddate - end date, PageTypes - list of selected page types, deviceTypes - list of selected deviceTypes
    *   Return      : list of cloneAttributesWrapper
    */
    @AuraEnabled
    public static  List<cloneAttributesWrapper> fetchFloorsetWrapper(Placement_Layout__c placLayout,date startdate,date enddate, List<String> PageTypes ,List<String> deviceTypes)
    {
        system.debug('p---PageTypes--'+PageTypes);
        system.debug('p---deviceTypes--'+deviceTypes);
        List<cloneAttributesWrapper> searchResults = new List<cloneAttributesWrapper>();  
        List<String>  Page_Div = new List<String>();
        for(String page : PageTypes){
            for(String device : deviceTypes){
                Page_Div.add(page.trim()+' - '+device.trim());
            }
        }
        // fetch floorset and layouts between selected start date and end date
        for(DGTL_Floorset_Plan__c floorset : [SELECT id,Name,Date__c,(SELECT id,Name,Page_Types__c,Floorset_Plan__c,
                                                                      Floorset_Plan__r.Name,Collection_Page_Name__c,
                                                                      Collection_Page_Url__c,Device_Type__c 
                                                                      FROM Placement_Layout__r 
                                                                      WHERE Device_Type__c IN :deviceTypes 
                                                                      AND Page_Types__c IN:PageTypes 
                                                                      AND Type__c = 'Layout' AND Brands__c=:placLayout.Brands__c) 
                                              FROM DGTL_Floorset_Plan__c WHERE Brands__c=:placLayout.Brands__c 
                                              AND ((Date__c>:startdate AND Date__c<:enddate) 
                                                   OR (Date__c=:startdate or Date__c=:enddate)) 
                                              order BY Date__c ])
        {
            List<String> tempPage_Devices = new List<String>();
            tempPage_Devices.addAll(Page_Div);
            System.debug('tempPage_Devices---'+JSON.serialize(tempPage_Devices));
            // mapping layouts to wrapper class
            if(floorset.Placement_Layout__r.size() > 0){
                for( Placement_Layout__c layout : floorset.Placement_Layout__r){
                    if(layout.Collection_Page_Name__c == placLayout.Collection_Page_Name__c){
                        cloneAttributesWrapper wrp = new cloneAttributesWrapper();
                        wrp.isSelected = false;
                        wrp.floorsetId = string.valueof(floorset.Id);
                        wrp.floorsetName = floorset.Name;
                        wrp.layout = layout; // layout
                        system.debug('---wrp---'+wrp);
                        searchResults.add(wrp);
                        integer index = tempPage_Devices.indexOf(layout.Page_Types__c+' - '+layout.Device_Type__c);
                        system.debug(layout.Page_Types__c+'---'+layout.Device_Type__c+'--------'+index);
                        tempPage_Devices.remove(index);
                    }
                }  
            }
            
            System.debug('tempPage_Devices--2-'+JSON.serialize(tempPage_Devices));
            
            for( String pageDiv : tempPage_Devices){
                system.debug(pageDiv.split(' - ')[1]+'---'+pageDiv.split(' - ')[0]+'--------');
                cloneAttributesWrapper wrp = new cloneAttributesWrapper();
                wrp.isSelected = false;
                wrp.floorsetId = string.valueof(floorset.Id);
                wrp.floorsetName = floorset.Name;
                Placement_Layout__c newlay = new Placement_Layout__c();
                newlay.Name = pageDiv + ' - TO BE CREATED';
                newlay.Brands__c = placLayout.Brands__c;
                newlay.Device_Type__c = pageDiv.split(' - ')[1].trim();
                newlay.Page_Types__c = pageDiv.split(' - ')[0].trim();
                newlay.Type__c = 'Layout';
                newlay.Floorset_Plan__c = floorset.Id;
                newlay.Collection_Page_Name__c = placLayout.Collection_Page_Name__c;
                newlay.Collection_Page_Url__c = placLayout.Collection_Page_Url__c;
                wrp.layout = newlay; // layout
                wrp.layoutTobeAdded = pageDiv + ' - TO BE CREATED';
                system.debug('---wrp---'+wrp);
                searchResults.add(wrp);
            }
        }
        System.debug('searchResults----'+JSON.serialize(searchResults));
        return searchResults;
    }
    
    
    /*
    *   Description : This Method is used to clone contents 
    *   Param       : placLayout - Placement_Layout__c, list_CloneContents - list of Placement_Content__c,  selectedLayouts - list of Placement_Layout__c
    *   Return      : list of cloneAttributesWrapper
    */
    @AuraEnabled
    public static  List<cloneAttributesWrapper> cloneContentsToLayout(list<Placement_Content__c> list_CloneContents,Placement_Layout__c placLayout , list<Placement_Layout__c> selectedLayouts)
    {
        List<cloneAttributesWrapper> saveResults = new List<cloneAttributesWrapper>();
        Set<Id> successsLayoutIdSet = new Set<Id>();
        Set<Id> floorsetIdSet = new Set<Id>();
        Map<Id,String> floorsetIdNameMap = new Map<Id,String>();
        List<Placement_Content_Detail__c> contentDetailsToCloneList;
        Map<Id,Placement_Content__c> successsContentIdMap = new Map<Id,Placement_Content__c>();
        Map<String,Map<String,Placement_Content__c>> layoutIdCloneIdNewContentMap = new Map<String,Map<String,Placement_Content__c>>();
        List<Placement_Content__c> clonedContentToInsert = new  List<Placement_Content__c>();
        Map<String,List<String>> dmlResultMap = new Map<String,List<String>>();
        List<Database.UpsertResult> updateLayoutResults;
       
       
        // upsert the incoming layouts & collect result
        updateLayoutResults = Database.upsert(selectedLayouts, false);
        for(Integer i=0;i<updateLayoutResults.size();i++){
            if(selectedLayouts[i].Floorset_Plan__c != null) floorsetIdSet.add(selectedLayouts[i].Floorset_Plan__c);
            //System.debug('selectedLayouts-----'+JSON.serialize(selectedLayouts[i]));
            String key = selectedLayouts[i].Id != null ? String.valueOf(selectedLayouts[i].Id) : selectedLayouts[i].Name ;
            if(updateLayoutResults.get(i).isSuccess()){
                dmlResultMap.put(key,new List<String>{'Layout Success'});
                successsLayoutIdSet.add(selectedLayouts[i].Id);
                
            }else{
                 System.debug('failure----'+updateLayoutResults[i].getErrors());
                 dmlResultMap.put(key,new List<String>{'Layout Failed'});
            }
        }
        
        //System.debug('dmlResultMap--1--'+JSON.serialize(dmlResultMap));
        
        // cloning the contents for all the successfully upserted layouts
        for( Placement_Layout__c layoutRec : [SELECT Id, Name,Floorset_Plan__c from Placement_Layout__c 
                                              WHERE Id IN:successsLayoutIdSet])
        {
            if(dmlResultMap.containsKey(String.valueOf(layoutRec.Id)) && dmlResultMap.get(layoutRec.Id).contains('Layout Success')) {	
                
                for(Placement_Content__c cont : list_CloneContents){
                    Placement_Content__c cloneCont =  cont.clone();
                    cloneCont.Compare_Type__c = '';
                    cloneCont.Placement_Layout__c = layoutRec.Id;
                    clonedContentToInsert.add(cloneCont);
                    layoutIdCloneIdNewContentMap.put(layoutRec.Id, new Map<String,Placement_Content__c>{cloneCont.getCloneSourceId() => cloneCont});
                }
            }
        }
        
        // insert new cloned contents
        Database.SaveResult[] saveResultsContents = Database.insert(clonedContentToInsert, false);
       //	DGTL_Layout.updateParentContentIds(clonedContentToInsert,map_ClonedIdCont); -- not sure why we used it
        
        // mapping success and error messages of contents 
        for(Integer i=0; i<saveResultsContents.size(); i++){
            String result = '';
            // checks Success content insert
            if (saveResultsContents[i].isSuccess()){
                result = 'Success Content :'+clonedContentToInsert[i].Placement_type__c+' - '+clonedContentToInsert[i].Main_Message__c;
                successsContentIdMap.put(clonedContentToInsert[i].Id,clonedContentToInsert[i]);
            }else{
                result = 'Content :'+clonedContentToInsert[i].Placement_type__c+' - '+clonedContentToInsert[i].Main_Message__c+' - '+' - Failed due to "';
                
                for(Database.Error err : saveResultsContents[i].getErrors()) {
                    result += err.getMessage().contains('duplicate') ? ' Duplicate' : ','+err.getMessage();
                }
                result += '"';
            }
            dmlResultMap.get(clonedContentToInsert[i].Placement_Layout__c).add(result);
        }
        
		//System.debug('dmlResultMap--2--'+JSON.serialize(dmlResultMap)); 
        
        // get content details of selected cloned contents 
        Set<Id> contentIdSet =  new Set<Id>();
        for(Placement_Content__c cont : list_CloneContents){
            if(cont.Id != null) contentIdSet.add(cont.Id);
        }
        
        // get content details related to selected contents to cloned 
        contentDetailsToCloneList = Database.query(DGTL_DataAccessor.getSobjectSoql(new Placement_Content_Detail__c())+ ' and  Placement_Content__c in: contentIdSet');
        System.debug('contentDetailsToCloneList----'+contentDetailsToCloneList);
        // cloning Content details
        if(!contentDetailsToCloneList.isEmpty()){
            List<Placement_Content_Detail__c> detailList = new List<Placement_Content_Detail__c>();
           
            for(Placement_Content__c cont : clonedContentToInsert) {
                List<Placement_Content_Detail__c> list_ContDetail = new List<Placement_Content_Detail__c>();
                for(Placement_Content_Detail__c contDet :contentDetailsToCloneList)
                {
                    Placement_Content_Detail__c newContDet = new Placement_Content_Detail__c();
                    newContDet = contDet.clone();
                    if(newContDet.Placement_Content__c == cont.getCloneSourceId()){
                        newContDet.Placement_Content__c = cont.Id;
                        detailList.add(newContDet);
                    }
                }
            }
            System.debug('detailList----'+detailList);
            if(!detailList.isEmpty()){
                Database.SaveResult[] saveResultsContDetails = Database.insert(detailList, false);
            }
            
        }
                                                                              
       // get floorset names to display on the ui page
        for(DGTL_Floorset_Plan__c  fp : [SELECT Id,Name FROM DGTL_Floorset_Plan__c WHERE Id IN:floorsetIdSet]) {
            floorsetIdNameMap.put(fp.Id,fp.Name);
        }                                                                                                                               
        
        System.debug('dmlResultMap--3--'+JSON.serialize(dmlResultMap));
        // mapping wrapper class with selected layouts and errorMessage
        for(Placement_Layout__c layoutRec : selectedLayouts){
            List<contentResultsWrapper> contentResults = new List<contentResultsWrapper>();
            String key = layoutRec.Id != null ? String.valueOf(layoutRec.Id) : layoutRec.Name ;
            cloneAttributesWrapper wrp = new cloneAttributesWrapper();
            wrp.floorsetId = layoutRec.Floorset_Plan__c;
            wrp.floorsetName = floorsetIdNameMap.get(layoutRec.Floorset_Plan__c);
            wrp.layout = layoutRec;
            
            for(string str : dmlResultMap.get(key)){
                contentResultsWrapper resWrap = new contentResultsWrapper();
                resWrap.isSuccess = str.contains('Success') ? true : false;
                resWrap.errorMessage = str;
                contentResults.add(resWrap);
            }
            
            wrp.list_contentResults = contentResults;
            saveResults.add(wrp);
        }
        //system.debug('---saveResults---'+saveResults);
        return saveResults;
        
    }
    
    
      /*
*   This Method is used to clone selected contents and update layout 
*   Component helper method : addContentsHpr
*/
   /* @AuraEnabled
    public static  List<cloneAttributesWrapper> cloneContentsToLayout(/*list<string> floorsetIds,list<Placement_Content__c> list_CloneContents,Placement_Layout__c placLayout , list<Placement_Layout__c> selectedLayouts/*, List<String> floorsetLayoutStringLis/)
   /* {
        system.debug('---list_CloneContents--'+list_CloneContents);
        //system.debug('---floorsetLayoutStringList--'+JSON.serialize(floorsetLayoutStringList));
        // variable declartion 
        list<Id> list_ClonedContIds = new list<Id>(); // id's of the contents to be cloned with details
        map<string,string> map_FloorsetIdName = new map<string,string>(); //get selected floorset name and id in map - FOR UI
        map<string,List<Placement_Layout__c>> map_FloorsetIdLayoutList = new map<string,List<Placement_Layout__c>>(); // new
        map<string,Placement_Layout__c> map_FloorsetIdLayout = new map<string,Placement_Layout__c>();
        map<string,string> map_layoutErrors = new map<string,string>();
        list<Placement_Content__c> list_TotalClonedContents = new list<Placement_Content__c>();
        //list<Placement_Content__c> list_ContentsToClone = new list<Placement_Content__c>();
        list<Placement_Content_Detail__c> list_CloneContDetails = new list<Placement_Content_Detail__c>();
        List<cloneAttributesWrapper> saveResults = new List<cloneAttributesWrapper>();
        map<string,list<string>> map_errlist = new map<string,list<string>>();
        map<string,string> map_layoutFloorset = new map<string,string>();
        map<Placement_Content__c,boolean> map_ContentStatus = new map<Placement_Content__c,boolean>();
        map<string,Placement_Content__c> map_ClonedIdCont = new map<string,Placement_Content__c>(); // used to update parent content
        
        map<Placement_Layout__c,String> map_LayoutFloorsetId = new map<Placement_Layout__c,String>();
        map<String,String> map_LayoutIdFloorsetId = new map<String,String>();
        list<string> floorsetIds = new list<string>();
        List<Placement_Layout__c> newLayouts = new List<Placement_Layout__c>();
        List<Placement_Layout__c> allSelectedLayouts = new List<Placement_Layout__c>();
        map<String,String> map_LayoutIdLayoutName = new map<String,String>();
        
        //------------------------------------------------------------------------------------------
        List<Database.UpsertResult> updateLayoutResults = Database.upsert(selectedLayouts, false);
       
        
        system.debug('--------------selectedLayouts---'+JSON.serialize(selectedLayouts));
        system.debug('--------------selectedLayouts- size--'+selectedLayouts.size());
        system.debug('--------------selectedLayouts- size--'+updateLayoutResults);

        List<ID> successsLayoutID = new List<ID>();
        for(Integer i=0;i<updateLayoutResults.size();i++){
         // String key = selectedLayouts[i].Id == null ? selectedLayouts[i].Name : selectedLayouts[i].Id ;
  		  floorsetIds.add(selectedLayouts[i].Floorset_Plan__c);
            //old
            map_layoutFloorset.put(selectedLayouts[i].Floorset_Plan__c, selectedLayouts[i].Id);
            // map_layoutFloorset.put( String.valueOf(map_FloorsetIdLayout.values().get(i).Id),String.valueOf(map_FloorsetIdLayout.values().get(i).Floorset_Plan__c));
            list<string> errlst = new list<string>();
            // if Layout is updated Success
            if (updateLayoutResults.get(i).isSuccess()){
                map_layoutErrors.put(selectedLayouts[i].Id,'Layout Success');
                //errlst.add('Layout Success');
                newLayouts.add(selectedLayouts[i]);
                successsLayoutID.add(selectedLayouts[i].Id);
                // if Layout update is Failed
            }else{
                map_layoutErrors.put(selectedLayouts[i].Id,'Layout Failed');
                errlst.add('Layout Failed');
                allSelectedLayouts.add(selectedLayouts[i]);
            }
            map_errlist.put(selectedLayouts[i].Name,errlst);
        }

        //------------------------------------------------------------------------------------------
        // get selected floorset name and id in map - FOR UI
        for(DGTL_Floorset_Plan__c flr : [select id,Name from DGTL_Floorset_Plan__c where id in : floorsetIds ])
        {
            map_FloorsetIdName.put(string.valueOf(flr.Id), flr.Name);
        }
        // get selected cloned content ids 
        for(Placement_Content__c cont : list_CloneContents)
        {
            list_ClonedContIds.add(cont.Id);
        }
        
        // get content details of selected cloned contents 
        list_CloneContDetails = Database.query(DGTL_DataAccessor.getSobjectSoql(new Placement_Content_Detail__c())+ ' and  Placement_Content__c in: list_ClonedContIds');
        system.debug('--list_CloneContDetails--'+list_CloneContDetails);
       
       
        
        for( Placement_Layout__c lays : newLayouts){
            map_LayoutFloorsetId.put(lays, lays.Floorset_Plan__c);
            map_LayoutIdFloorsetId.put(lays.Id, lays.Floorset_Plan__c);
            
        }
     
       
        // cloning selected contents for all selected floorset/layouts
        // checks for Success layouts
        for( Placement_Layout__c layoutRec : [SELECT Id, NAME ,Floorset_Plan__c from Placement_Layout__c where ID in:successsLayoutID]){
            list<string> errlst = new list<string>();
            errlst.add('Layout Success');
            map_errlist.put(layoutRec.Name,errlst);
            allSelectedLayouts.add(layoutRec);
            system.debug('---map_layoutErrors--- output---'+map_layoutErrors.get(layoutRec.Id));
            if(map_layoutErrors.get(layoutRec.Id) == 'Layout Success')
            {	
                map_LayoutIdLayoutName.put(layoutRec.Id,layoutRec.Name);
                list<Placement_Content__c> list_Clone = new list<Placement_Content__c>();
                for(Placement_Content__c cont : list_CloneContents){
                    Placement_Content__c cloneCont =  new Placement_Content__c();
                    cloneCont = cont.clone();
                    cloneCont.Compare_Type__c = '';
                    map_ClonedIdCont.put(string.valueOf(cloneCont.getCloneSourceId()),cloneCont);
                    cloneCont.Placement_Layout__c = layoutRec.Id;
                    list_Clone.add(cloneCont);
                }
                list_TotalClonedContents.addAll(list_Clone);
            }
        }
        
        // creating new cloned contents and updating error messages with Failed
        Database.SaveResult[] saveResultsContents = Database.insert(list_TotalClonedContents, false);
        // this method is used to update parent content id for AB Test/Takedown/Contingency contents
        DGTL_Layout.updateParentContentIds(list_TotalClonedContents,map_ClonedIdCont);
        system.debug('-------------list_TotalClonedContents----'+list_TotalClonedContents);
        system.debug('-------------saveResultsContents----'+saveResultsContents);
        
        for(Integer i=0;i<saveResultsContents.size();i++){
            system.debug('-saveResultsContents-'+saveResultsContents[i].Id+'----'+saveResultsContents[i]);
            list<string> list_error = map_errlist.get(map_LayoutIdLayoutName.get(list_TotalClonedContents[i].Placement_Layout__c));
           // if(list_error == null) list_error = new list<string> ();
            if (!saveResultsContents[i].isSuccess()){
                map_ContentStatus.put(list_TotalClonedContents[i], false);
                string errorMessage = 'Content :'+list_TotalClonedContents[i].Placement_type__c+' - '+list_TotalClonedContents[i].Main_Message__c+' - '+' - Failed due to "';
                for(Database.Error err : saveResultsContents[i].getErrors()) {
                    if(err.getMessage().contains('duplicate')){
                        errorMessage += ' Duplicate';
                    }
                    else{
                        errorMessage += ','+err.getMessage();
                    }
                }
                errorMessage += '"';
                list_error.add(errorMessage);
                map_errlist.put(map_LayoutIdLayoutName.get(list_TotalClonedContents[i].Placement_Layout__c),list_error);
                //map_layoutErrors.put(String.valueOf(list_TotalClonedContents[i].Placement_Layout__c),errorMessage);
            }else{
                map_ContentStatus.put(list_TotalClonedContents[i], true);
                system.debug('----'+list_TotalClonedContents[i].Id);
                string errorMessage = 'Success Content :'+list_TotalClonedContents[i].Placement_type__c+' - '+list_TotalClonedContents[i].Main_Message__c;
               // map_layoutErrors.put(String.valueOf(list_TotalClonedContents[i].Placement_Layout__c),errorMessage);
                list_error.add(errorMessage);
                map_errlist.put(map_LayoutIdLayoutName.get(list_TotalClonedContents[i].Placement_Layout__c),list_error);
            }
            
        }
        // cloning Content details
        if(!list_CloneContDetails.isEmpty())
        {
            list<Placement_Content_Detail__c> list_TotalCloneContDetails = new  list<Placement_Content_Detail__c>();
            for(Placement_Content__c cont :list_TotalClonedContents)
            {
                if(map_ContentStatus.get(cont)){
                    list<Placement_Content_Detail__c> list_ContDetail = new list<Placement_Content_Detail__c>();
                    for(Placement_Content_Detail__c contDet :list_CloneContDetails)
                    {
                        Placement_Content_Detail__c newContDet = new Placement_Content_Detail__c();
                        newContDet = contDet.clone();
                        if(newContDet.Placement_Content__c == cont.getCloneSourceId()){
                            newContDet.Placement_Content__c = cont.Id;
                            list_TotalCloneContDetails.add(newContDet);
                        }
                    }
                }
            }
            if(!list_TotalCloneContDetails.isEmpty())
            {
                Database.SaveResult[] saveResultsContDetails = Database.insert(list_TotalCloneContDetails, false);
            }
            
        }
        system.debug('-------map_errlist--------'+map_errlist);
        system.debug('-------map_LayoutFloorsetId--------'+map_LayoutFloorsetId);

        // mapping wrapper class with selected layouts and errorMessage
        for(Placement_Layout__c layoutRec : allSelectedLayouts){
            String key = layoutRec.Id == null ? layoutRec.Name : layoutRec.Id ;
            cloneAttributesWrapper wrp = new cloneAttributesWrapper();
            list<contentResultsWrapper> contentResults = new list<contentResultsWrapper>();
            wrp.floorsetId = layoutRec.Floorset_Plan__c;
            wrp.floorsetName = map_FloorsetIdName.get(layoutRec.Floorset_Plan__c);
            wrp.layout = layoutRec;
            for(string str : map_errlist.get(layoutRec.Name)){
                contentResultsWrapper resWrap = new contentResultsWrapper();
                if(str.contains('Success')){
                    resWrap.isSuccess = true;
                }
                resWrap.errorMessage = str;
                contentResults.add(resWrap);
            }
            wrp.list_contentResults = contentResults;
            saveResults.add(wrp);
        }
        //system.debug('---saveResults---'+saveResults);
        return saveResults;
    }*/
    
    
    // - get Dependant PickList
    @AuraEnabled 
    public static Map<String, List<String>> getDependentMap(sObject objDetail, string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType==null){
            return objResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        return objResults;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){            
        }
        
    }
  
    public class cloneAttributesWrapper{
        @AuraEnabled public boolean isSelected {get;set;}
        @AuraEnabled public String floorsetId {get;set;}
        @AuraEnabled public String floorsetName {get;set;}
        @AuraEnabled public String layoutTobeAdded {get;set;}
        // @AuraEnabled public boolean isSuccess {get;set;}
        // @AuraEnabled public String errorMessage {get;set;}
        // @AuraEnabled public list<String> errorlist {get;set;}
        @AuraEnabled public list<contentResultsWrapper> list_contentResults {get;set;}
        @AuraEnabled public Placement_Layout__c layout {get;set;}
        public cloneAttributesWrapper()
        {
            floorsetId = '';
            //isSuccess = false;
            // errorMessage = '';
            layout = new Placement_Layout__c();
            floorsetName = '';
            isSelected = false;
            layoutTobeAdded = '';
            // errorlist = new list<String>();
            list_contentResults = new list<contentResultsWrapper>(); 
        }
    }
    
    public class contentResultsWrapper{
        @AuraEnabled public boolean isSuccess {get;set;}
        @AuraEnabled public String errorMessage {get;set;}
        public contentResultsWrapper()
        {
            isSuccess = false;
            errorMessage = '';
        }
        
        
    }
    
}