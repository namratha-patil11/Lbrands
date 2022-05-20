/**
* @description	Implements the controller logics for compare tab 
* @author		Vipul Mittal
* @date			01 Aug 2019
*/

public class DGTL_ComparePlcLayout_Ctr 
{
     /**
    * @description	Get the current user brand
    * @author		Vipul Mittal
    * @date			01 Aug 2019
    * @return		String - brand name
    */
    @AuraEnabled
    public static string getUserBrandHpr()
    {
        return DGTL_DataAccessor.getUserBrand();  
        
    }
    
    
     /**
    * @description	Get the picklist options from access management read only fields for Placement Content
    * @author		Vipul Mittal
    * @date			10 March 2020
    * @return		DGTL_ComparePlcLayout_Ctr.SelectOption (Inner class contains label and value)
    */
    @AuraEnabled
    public static List<SelectOption> getFields(){
        List<SelectOption> fieldOptionList = new List<SelectOption>();
        Map<String,String> fieldLabelMap = DGTL_Util.getReadOnlyPickListFields('Placement_Content__c');
        Set<String> compareFields = getCompareFieldSetValues('DGTL_Compare_Fields','Placement_Content__c');
        
        for(String str : fieldLabelMap.keySet()){
            if(compareFields.contains(str.toLowerCase())) 
                fieldOptionList.add(new SelectOption(fieldLabelMap.get(str),str));
        }
        
        return fieldOptionList;
    }
    
    /**
    * @description	Get the user preference fields for compare from access management
    * @author		Vipul Mittal
    * @date			09 March 2020
    * @param		String - brand name
    * @return		String - ( JSON DGTL_WrapperClasses.UserComparePreferences )
    */
     @AuraEnabled
    public static String getUserPreferenceSettings(String brand){
        DGTL_WrapperClasses.UserComparePreferences userPref = new DGTL_WrapperClasses.UserComparePreferences();
        userPref.hasUserPreference = false;
        for(DGTL_Access_Management__c accMangmnt : [SELECT Read_Only_Fields__c,RecordTypeId,Object_Name__c,UserOrProfileId__c,Brands__c
                                                    FROM DGTL_Access_Management__c 
                                                    WHERE RecordType.DeveloperName = 'Compare_Setup' 
                                                    AND Object_Name__c = 'Placement_Content__c'
                                                    AND (UserOrProfileId__c = :UserInfo.getUserId() OR UserOrProfileId__c = null) 
                                                    AND Brands__c = :brand])
        {
            userPref.accMgt = accMangmnt;

            if(String.isNotBlank(accMangmnt.UserOrProfileId__c) && 
               accMangmnt.UserOrProfileId__c.equals(UserInfo.getUserId()))
            {
                userPref.hasUserPreference =  true;
                break;
            }
        }
        
        if(userPref.accMgt != null){
            userPref.options = getFields();
            userPref.selectedOptions = new List<String>();
            if(String.isNotBlank(userPref.accMgt.Read_Only_Fields__c)){
                for(String str :userPref.accMgt.Read_Only_Fields__c.split(';') ){
                    userPref.selectedOptions.add(str);
                }
            }
        }else{
             throw new AuraException('No Compare Setup Found!');
        }
        
        return JSON.serialize(userPref);
    }
    
    
    /**
    * @description	Insert/Update the current user preference fields records for compare to access management
    * @author		Vipul Mittal
    * @date			09 March 2020
    * @param		String - brand name
    * @return		String - ( JSON DGTL_WrapperClasses.UserComparePreferences )
    */
    @AuraEnabled
    public static String saveUserPreference(String preferenceJSON){
        DGTL_WrapperClasses.UserComparePreferences userPref = (DGTL_WrapperClasses.UserComparePreferences)JSON.deserialize(preferenceJSON,DGTL_WrapperClasses.UserComparePreferences.class);
        try{
            if(userPref.hasUserPreference){
                userPref.accMgt.Read_Only_Fields__c = userPref.selectedOptions != null && userPref.selectedOptions.size() > 0 ? 
                    String.join(userPref.selectedOptions, ';') : '';
                update userPref.accMgt;
            }else{
                DGTL_Access_Management__c accessManagement = userPref.accMgt.clone(false,false,false,false);
                accessManagement.UserOrProfileId__c = UserInfo.getUserId();
                accessManagement.Read_Only_Fields__c = userPref.selectedOptions != null && userPref.selectedOptions.size() > 0 ? 
                    String.join(userPref.selectedOptions, ';') : '';
                insert accessManagement;
                SYstem.debug('accessManagement----'+JSON.serialize(accessManagement));
            }
        }catch(Exception e){
            throw new AuraException('Error!! '+e.getMessage());
        }
        return getUserPreferenceSettings(userPref.accMgt.Brands__c);
    }
     @AuraEnabled
    public static void saveAcknowledgeRecord(String layoutId){
        Digital_Live_Users__c ackRec;
        try{
            ackRec = getLastAknowledgeRecord(layoutId);
            ackRec.Last_Poll_Time__c = System.now();
            update ackRec;
        }catch(QueryException qe){
            try{
               insert new Digital_Live_Users__c(
                   User__c = UserInfo.getUserId(),
                   Layout__c = layoutId,
                   Last_Poll_Time__c = System.now(),
                   Tab_Name__c = 'Compare'
               ); 
            }catch(Exception e){
                throw new AuraException('ERROR!! '+e.getMessage());
            }
        }
    }
    
     @AuraEnabled
    public static Map<String,List<History_Tracking__c>> getHistory(String layoutId, String contentId, String brand){
        System.debug('layoutId---'+layoutId+'--contentId---'+contentId);
        Map<String,List<History_Tracking__c>> objHistoryMap = new Map<String,List<History_Tracking__c>>();
        Set<Id> contentDetailIdSet = new Set<Id>();
        DateTime lastpollTime;
        Id historyRecTypeId = Schema.SObjectType.History_Tracking__c.getRecordTypeInfosByName().get('History Records').getRecordTypeId();
        
        List<String> selectedFields = ((DGTL_WrapperClasses.UserComparePreferences)JSON.deserialize(getUserPreferenceSettings(brand), DGTL_WrapperClasses.UserComparePreferences.class)).selectedOptions;
        selectedFields.addAll(getCompareFieldSetValues('DGTL_Compare_Fields','Placement_Content_Detail__c'));
        
        DGTL_WrapperClasses.UserComparePreferences userPref = new DGTL_WrapperClasses.UserComparePreferences();
        for(Placement_Content_Detail__c pcd : [SELECT Id FROM Placement_Content_Detail__c WHERE Placement_Content__c = :contentId]){
            contentDetailIdSet.add(pcd.Id);
        }
        
         Digital_Live_Users__c ackRec;
        try{
            lastpollTime = getLastAknowledgeRecord(layoutId).Last_Poll_Time__c;
        }catch(Exception qe){}
        
        System.debug('lastpollTime----'+lastpollTime);
        
        String query = 'SELECT Id,Name,Field_Name__c,Object_Name__c,Old_Value__c,New_Value__c,LastModifiedById,LastModifiedBy.Name,Field_API__c,LastModifiedDate FROM History_Tracking__c'; 
        query += ' WHERE RecordTypeId=:historyRecTypeId AND (Placement_Content__c=:contentId OR Placement_Content_Detail__c IN :contentDetailIdSet) AND Field_API__c IN:selectedFields' ;
        query +=  lastpollTime != null ? ' AND LastModifiedDate >= :lastpollTime' : '';
        query += ' ORDER by LastModifiedDate DESC LIMIT 100';
        
        System.debug('query----'+query);
        
        for(History_Tracking__c historyRec : Database.query(query)){
            if(!objHistoryMap.containskey(historyRec.Object_Name__c)) objHistoryMap.put(historyRec.Object_Name__c,new List<History_Tracking__c>());
            objHistoryMap.get(historyRec.Object_Name__c).add(historyRec);
            
            //temporary
            if(!objHistoryMap.containskey('All')) objHistoryMap.put('All',new List<History_Tracking__c>());
            objHistoryMap.get('All').add(historyRec);
        }
        System.debug('objHistoryMap000'+objHistoryMap);
        return objHistoryMap;
        
    } 
    
    @AuraEnabled
    public static String getContentHasHistory(String layoutId, String brand){
        Set<String> contentWithHistoryIdSet = new Set<String>();
        DateTime lastpollTime;
        Id historyRecTypeId = Schema.SObjectType.History_Tracking__c.getRecordTypeInfosByName().get('History Records').getRecordTypeId();
        
        List<String> selectedFields = ((DGTL_WrapperClasses.UserComparePreferences)JSON.deserialize(getUserPreferenceSettings(brand), DGTL_WrapperClasses.UserComparePreferences.class)).selectedOptions;
        selectedFields.addAll(getCompareFieldSetValues('DGTL_Compare_Fields','Placement_Content_Detail__c'));
        
        try{
            lastpollTime = getLastAknowledgeRecord(layoutId).Last_Poll_Time__c;
        }catch(Exception qe){}
        
        String query = 'SELECT Placement_Content__c,Placement_Content_Detail__r.Placement_Content__c FROM History_Tracking__c'; 
        query += ' WHERE RecordTypeId=:historyRecTypeId AND (Placement_Content__r.Placement_Layout__c=:layoutId OR Placement_Content_Detail__r.Placement_Content__r.Placement_Layout__c = :layoutId) AND Field_API__c IN:selectedFields' ;
        query +=  lastpollTime != null ? ' AND LastModifiedDate >= :lastpollTime' : '';
        query += ' ORDER by LastModifiedDate DESC LIMIT 100';
        
        for(History_Tracking__c ht : Database.query(query)){
            String contentId = String.isNotBlank(ht.Placement_Content__c) ? ht.Placement_Content__c : ht.Placement_Content_Detail__r.Placement_Content__c;
            contentWithHistoryIdSet.add(contentId);
        }
        
        return JSON.serialize(contentWithHistoryIdSet);
    }
    
    private static Digital_Live_Users__c getLastAknowledgeRecord(String layoutId){
        return [Select Id,User__c,Last_Poll_Time__c 
                FROM Digital_Live_Users__c 
                WHERE Layout__c=:layoutId AND Tab_Name__c='Compare' 
                AND User__c=:UserInfo.getUserId() LIMIT 1];
    }
 
    
        
    @AuraEnabled
    public static AuraResponse getEditorialNames(Boolean isInit, String searchString , String brand) {
        System.debug('isInit===='+isInit);
        List<SelectOption> editorialNames = new List<SelectOption>();
        //editorialNames.add(new MassMailerConstants.SelectOption('--None--', ''));
        
        String query = 'SELECT Collection_Page_Name__c FROM Placement_Layout__c WHERE Page_Types__c = \'Editorials\' AND Brands__c =:brand  AND Collection_Page_Name__c != null';
        if(!isInit) query += ' AND Collection_Page_Name__c LIKE \'%'+searchString+'%\'';
        query += ' LIMIT 20';
        
        System.debug('query----'+query);
        for(Placement_Layout__c pl : Database.query(query)) {
            editorialNames.add(new SelectOption(pl.Collection_Page_Name__c, pl.Collection_Page_Name__c));                                               
        }
        AuraResponse response = new AuraResponse(true, 'SUCCESS', JSON.serialize(editorialNames));
        
        return response;
    }
    
    @AuraEnabled
    public static  map<String, list<String>> setUpValues()
    {
        
        List<String> list_PageTypes = new List<String>();
        map<String, list<String>> map_PickList = new map<String, list<String>>();
        for(Schema.PicklistEntry pType : Placement_Layout__c.Page_Types__c.getDescribe().getPicklistValues())
        {
            list_PageTypes.add(pType.getValue());            
        }
        map_PickList.put('PageType', list_PageTypes);
        List<String> list_PageTypes1 = new List<String>();
        for(Schema.PicklistEntry pType : Placement_Layout__c.Brands__c.getDescribe().getPicklistValues())
        {
            list_PageTypes1.add(pType.getValue());            
        }
        map_PickList.put('Brands', list_PageTypes1);
        return map_PickList;
    }
    
    @AuraEnabled
    public static Placement_Layout__c fetchLayoutData(string layoutId)
    {
        Placement_Layout__c layoutRec = new Placement_Layout__c();
        List<Placement_Layout__c> layoutList = [SELECT id,name,Brands__c,Page_Types__c,Floorset_Plan__c from Placement_Layout__c where id=:layoutId LIMIT 1];
        if(layoutList != null && layoutList.size() > 0){
            layoutRec = layoutList[0];
            system.debug('layoutRec---'+layoutRec);
        }
        return layoutRec;
    }
    
    private static Set<String> getCompareFieldSetValues(String fieldSetName, String objectName){
        Set<String> fieldSet = new Set<String>();
        for(Schema.FieldSetMember f : DGTL_Util.getFieldSetValues(fieldSetName, objectName)) {
            fieldSet.add(f.getFieldPath().toLowerCase());
        }
        return fieldSet;
    }
    
    @AuraEnabled
    public static finalWpr fetchData(string brand, String pageType,Date startDate,Date endDate, String deviceType, String editorialName, String userPreferenceJSON)
    {
        DGTL_Access_Management__c accessMgmt;
        finalWpr fnlWpr;
        try{
            DGTL_WrapperClasses.UserComparePreferences userPref = (DGTL_WrapperClasses.UserComparePreferences)JSON.deserialize(userPreferenceJSON,DGTL_WrapperClasses.UserComparePreferences.class);
            accessMgmt = userPref.accMgt;
        }catch(QueryException qe){
            throw new AuraException('No Compare Setup Found!'); //TODO:
        }
        
        if(accessMgmt != null){
            fnlWpr = new finalWpr();
            if(String.isNotBlank(accessMgmt.Read_Only_Fields__c)){
                for(String str :accessMgmt.Read_Only_Fields__c.split(';') ){
                    fnlWpr.set_FieldsToDisplay.add(str.toLowerCase());
                }
            }
        }else{
            throw new AuraException('No Compare Setup Found!'); //TODO:
        }
        
        List<Placement_Layout__c> plLayoutList;
        
        //TODO: to make it dynamic : AccessManagement Object
        //fnlWpr.set_FieldsToDisplay.add('Name');
        /* fnlWpr.set_FieldsToDisplay.add('Category__c');
        fnlWpr.set_FieldsToDisplay.add('Link__c');
        fnlWpr.set_FieldsToDisplay.add('Main_Message__c');
        fnlWpr.set_FieldsToDisplay.add('Offer_Type__c');
        fnlWpr.set_FieldsToDisplay.add('Page_Name__c');
        fnlWpr.set_FieldsToDisplay.add('Shot_Number__c');
        fnlWpr.set_FieldsToDisplay.add('Style_Info__c');*/
        //fnlWpr.set_FieldsToDisplay.add('S_No__c');
        //fnlWpr.set_FieldsToDisplay.add('Active__c');
        
        fnlWpr.contDetailFields  = new List<String>();
        List<pLayoutWpr> list_pLayoutWpr = new List<pLayoutWpr>();
        
        Set<String> set_FieldsToCheck = new Set<String>();
        Map<Id,Set<String>> map_PayLibraries = new Map<Id,Set<String>>();
        Map<String,Placement_Content__c> map_PreviousPlayLibraries = new Map<String,Placement_Content__c>();
        system.debug(pageType);
        //Date startDate = System.today().addDays(-200);
        //Date endDate = System.today();
        String pContentFields = String.join(new List<String>(fnlWpr.set_FieldsToDisplay), ', ');
        String pContentUIFields = !fnlWpr.set_FieldsToDisplay.contains('id') ? 'Id,': '';
        pContentUIFields =  !fnlWpr.set_FieldsToDisplay.contains('name') ? pContentUIFields+'Name,' : pContentUIFields;
        pContentUIFields = !fnlWpr.set_FieldsToDisplay.contains('placement_type__c') ? pContentUIFields+'Placement_type__c,' : pContentUIFields;
        pContentUIFields = !fnlWpr.set_FieldsToDisplay.contains('placement_library__c') ? pContentUIFields+'Placement_Library__c,' : pContentUIFields;
        pContentUIFields = !fnlWpr.set_FieldsToDisplay.contains('type__c') ? pContentUIFields+'Type__c,' : pContentUIFields;
        pContentUIFields = !fnlWpr.set_FieldsToDisplay.contains('image__c') ? pContentUIFields+'Image__c,' : pContentUIFields;
        pContentUIFields = !fnlWpr.set_FieldsToDisplay.contains('s_no__c') ? pContentUIFields+'S_No__c,' : pContentUIFields; 
        pContentUIFields = !fnlWpr.set_FieldsToDisplay.contains('ab_test_name__c') ? pContentUIFields+'AB_Test_Name__c,' : pContentUIFields;
        pContentUIFields = !fnlWpr.set_FieldsToDisplay.contains('main_message__c') ? pContentUIFields+'main_message__c,' : pContentUIFields;
        pContentUIFields += pContentFields;
        pContentUIFields = pContentUIFields.removeEnd(',');
        String pContentInnerQuery = '(SELECT Placement_Library__r.Name,'+pContentUIFields+' FROM Placement_Content__r WHERE Active__c = True AND (Type__c = \'Controlled\' OR Type__c = \'Takedown\' OR Type__c = \'AB Test\'  OR Type__c = \'Contingency\') ORDER BY S_No__c)';
        String pLayoutQuery = 'SELECT Id,Collection_Page_Url__c,Page_Types__c,Collection_Page_Name__c,Name,Device_Type__c,'+pContentInnerQuery+' FROM Placement_Layout__c WHERE brands__c =: brand AND Is_Deleted__c = false and Page_Types__c =: pageType  and Device_Type__c =:deviceType AND Type__c = \'Layout\' and Date_Formula__c >=: startDate AND Date_Formula__c <=: endDate';
        if(pageType.equalsIgnoreCase('Editorials')) pLayoutQuery += ' AND Collection_Page_Name__c = :editorialName';
         pLayoutQuery += ' ORDER BY Date_Formula__c,Time_No__c';
        //for(Placement_Layout__c pLay : [SELECT Id,Name,(SELECT Id,Name,Main_Message__c,Style_Info__c,Image__c,Placement_Library__c,Placement_Library__r.Name FROM Placement_Content__r) FROM Placement_Layout__c ORDER BY Date_Formula__c LIMIT 10])
        System.debug('pLayoutQuery----'+pLayoutQuery);
        plLayoutList = Database.query(pLayoutQuery);
        System.debug('===='+JSON.serialize(plLayoutList));
        
        Integer i = 0;
        if(plLayoutList != null && plLayoutList.size() > 0)
        {
            Set<Id> pContentIds = new Set<Id>();
            Map<Id,List<Placement_Content_Detail__c>> contentIdDetailsMap  = new Map<Id,List<Placement_Content_Detail__c>> ();
            // collect the content Ids to query content Details
            for(Placement_Layout__c pLay : plLayoutList){
                for(Placement_Content__c pCon : pLay.Placement_Content__r){
                    pContentIds.add(pCon.Id);
                }
            }
            
            System.debug('pContentIds-----'+pContentIds);
            
            // query content details
            if(pContentIds.size() > 0){
                fnlWpr.contDetailFields = new List<String>{'Copy__c','Link_Text__c','Sub_Type__c','Slides__c'};
                    String cDetailQueryFields = String.join(new List<String>(fnlWpr.contDetailFields), ', ');
                cDetailQueryFields += ',S_No__c';
                List<Placement_Content_Detail__c> pcDetailList =  Database.query('SELECT Id,Name,Placement_Content__c,'+cDetailQueryFields+' FROM Placement_Content_Detail__c WHERE Placement_Content__c IN : pContentIds  ORDER BY CreatedDate DESC ');
                //System.debug('pcDetailList-----'+pcDetailList);
                if(pcDetailList != null && pcDetailList.size() > 0){
                    
                    for(Placement_Content_Detail__c pcDetail : pcDetailList)
                    {
                        if(!contentIdDetailsMap.containsKey(pcDetail.Placement_Content__c)){
                            contentIdDetailsMap.put(pcDetail.Placement_Content__c,new List<Placement_Content_Detail__c>());                           
                        } 
                        contentIdDetailsMap.get(pcDetail.Placement_Content__c).add(pcDetail);
                    }
                }
            }
            
            //compare
            for(Placement_Layout__c pLay : plLayoutList)
            {
                pLayoutWpr fWpr = new pLayoutWpr();
                List<Id> contentIds = new List<Id>();
                Set<String> comparedPreviousContentDetails = new Set<String>();
                fWpr.plcLayout = pLay;
                for(Placement_Content__c pCon : pLay.Placement_Content__r)
                {
                    plcContentWpr pWpr = new plcContentWpr();
                    System.debug('pCon---type---'+pCon.Type__c);
                    // compare content
                    if(pCon.Placement_Library__c != Null) 
                    { 
                        String abTestName = String.isNotBlank(pCon.AB_Test_Name__c) ? pCon.AB_Test_Name__c : '';
                        fWpr.set_PlcLaibraryIds.add(pCon.Placement_Library__c+ '-' +pCon.Type__c + '-' + abTestName);
                        map_PreviousPlayLibraries.put(pLay.Id+'-'+pCon.Placement_Library__c+'-'+pCon.Type__c + '-' + abTestName,pCon);
                        if(map_PayLibraries.get(pLay.Id) == Null) map_PayLibraries.put(pLay.Id,new Set<String>());
                        map_PayLibraries.get(pLay.Id).add(pCon.Placement_Library__c + '-' +pCon.Type__c + '-' + abTestName);
                        
                        if(i > 0)
                        {
                            Id previousPlayId = list_pLayoutWpr[i-1].plcLayout.Id;
                            //Map<String,Map<String,String>> fieldChangesMap = new  Map<String,Map<String,String>>();
                            if(map_PayLibraries.get(previousPlayId) != Null)
                            {
                                if(map_PayLibraries.get(previousPlayId).contains(pCon.Placement_Library__c + '-' +pCon.Type__c + '-' + abTestName))
                                {
                                    pwpr.changeResult.updateResult = new List<CompareUpdateResult>();
                                    comparedPreviousContentDetails.add(pCon.Placement_Library__c + '-' +pCon.Type__c + '-' + abTestName);
                                    Boolean isChanged = false;
                                    for(String field : fnlWpr.set_FieldsToDisplay)
                                    {
                                        System.debug('field-----'+field);
                                        System.debug('actual value-----'+pCon.get(field));
                                        System.debug('old value-----'+map_PreviousPlayLibraries.get(previousPlayId+'-'+pCon.Placement_Library__c+'-'+pCon.Type__c + '-' + abTestName).get(field));
                                        if(pCon.get(field) != map_PreviousPlayLibraries.get(previousPlayId+'-'+pCon.Placement_Library__c+'-'+pCon.Type__c + '-' + abTestName).get(field))
                                        {
                                            String label = field.endsWith('__c') ? field.removeEnd('__c') :field;
                                            label = label.contains('_') ? label.replace('_',' ') : label;
                                            pwpr.changeResult.updateResult.add(getUpdateResult(label,String.valueOf(pCon.get(field)),String.valueOf(map_PreviousPlayLibraries.get(previousPlayId+'-'+pCon.Placement_Library__c+'-'+pCon.Type__c + '-' + abTestName).get(field))));
                                            isChanged = true;
                                           
                                            pWpr.changedFields += label + ', ';
                                        }
                                    }
                                    if(isChanged)
                                    {
                                        pWpr.type = 'C'; //Changed
                                        pWpr.changedFields = pWpr.changedFields.removeEnd(', ');
                                        //pWpr.changedInfo = '<b>Content has been updated with the following field(s) : </b><br/>'+pWpr.changedFields+'<br/><br/>';
                                    }
                                    else
                                    {
                                        pWpr.type = 'S'; //Same
                                        //pWpr.changedInfo = '<b>There are no changes in Content.</b><br/><br/>';
                                    }
                                    
                                    System.debug('pCon.name===='+pCon.Name);
                                    List<Placement_Content_Detail__c> oldPLDetailsList = contentIdDetailsMap.get(map_PreviousPlayLibraries.get(previousPlayId+'-'+pCon.Placement_Library__c+'-'+pCon.Type__c + '-' + abTestName).Id);
                                    System.debug('oldPLDetailsList----'+oldPLDetailsList);
                                    System.debug('contentIdDetailsMap====='+contentIdDetailsMap+'======='+contentIdDetailsMap.containsKey(pCon.Id));
                                   // Boolean hasAdd = false;
                                   // Boolean hasRemove = false;
                                   // String UpdatedData = '';
                                    pwpr.changeResult.detailChanges = new List<ComparedResult>();
                                    
                                    //---compare content details starts----
                                    if(contentIdDetailsMap != null && contentIdDetailsMap.containsKey(pCon.Id)){
                                        Integer recCount = 0;
                                       // Map<Id,String> removedRecMap = new Map<Id,String>();
                                        Map<Id,Placement_Content_Detail__c> removedDetailRecMap = new Map<Id,Placement_Content_Detail__c>();
                                        for(Placement_Content_Detail__c pConDetail : contentIdDetailsMap.get(pCon.Id)){
                                            ComparedResult cr = new ComparedResult();
                                            String copy = String.isNotBlank(pConDetail.Copy__c) ? pConDetail.Copy__c : '';
                                            String url = String.isNotBlank(pConDetail.Link_Text__c) ? pConDetail.Link_Text__c : '';
                                            cr.name = copy + ' ~~ ' + url;
                                            cr.updateResult = new List<CompareUpdateResult>();
                                            
                                            PLContentDetailWpr contDetail = new PLContentDetailWpr();
                                            contDetail.pConDetail = pConDetail;
                                            contDetail.type = 'S';
                                            System.debug('i======'+i);
                                            System.debug('oldPLDetailsList======'+oldPLDetailsList);
                                            if(oldPLDetailsList != null && oldPLDetailsList.size() > 0 && oldPLDetailsList.size() - 1 >= recCount){
                                                
                                                //collect all ids
                                                for(Placement_Content_Detail__c oldDetail : oldPLDetailsList){
                                                    removedDetailRecMap.put(oldDetail.Id,oldDetail);
                                                    //removedRecMap.put(oldDetail.Id,oldDetail.Name);
                                                }
                                                
                                                Placement_Content_Detail__c recToCompare;
                                                
                                                for(Placement_Content_Detail__c oldDetail : oldPLDetailsList){
                                                    if( (oldDetail.Slides__c + oldDetail.Link_Text__c + oldDetail.Sub_Type__c + oldDetail.Copy__c) == (pConDetail.Slides__c + pConDetail.Link_Text__c + pConDetail.Sub_Type__c + pConDetail.Copy__c) && removedDetailRecMap.keySet().contains(oldDetail.Id)){
                                                        recToCompare = oldDetail;
                                                       // removedRecMap.remove(oldDetail.Id);
                                                        removedDetailRecMap.remove(oldDetail.Id);
                                                        break;
                                                    }
                                                }
                                                if(recToCompare != null){
                                                    for(String field : fnlWpr.contDetailFields){
                                                        if( pConDetail.get(field) != recToCompare.get(field)){
                                                            field = field.endsWith('__c') ? field.removeEnd('__c') :field;
                                                            field = field.contains('_') ? field.replace('_',' ') : field;
                                                            cr.updateResult.add(getUpdateResult(field,String.valueOf(pConDetail.get(field)),String.valueOf( recToCompare.get(field))));
                                                            contDetail.changedFields += field + ', ';
                                                            contDetail.type = 'C';
                                                            pWpr.type = 'C';
                                                        }
                                                    }
                                                     if(contDetail.type != 'C' && pConDetail.get('S_No__c') != recToCompare.get('S_No__c')){
                                                        cr.status = 'Resequenced';
                                                    }
                                                    contDetail.changedFields = contDetail.type == 'C' ? contDetail.changedFields.removeEnd(', ') : contDetail.changedFields;
                                                    
                                                    if(String.isNotBlank(contDetail.changedFields)){
                                                        cr.status = 'Update';
                                                       // UpdatedData += pConDetail.S_No__c+'-'+pConDetail.Link_Text__c + ' : ' + contDetail.changedFields+'<br/>';
                                                    }
                                                    
                                                }else{
                                                    pWpr.type = 'C';
                                                    cr.status = 'New Value';
                                                    //hasAdd = true;
                                                    //pWpr.changedInfo = getChangesInfo(pWpr.changedInfo, pConDetail.Name + ' : Add \n');
                                                    contDetail.type = 'N';
                                                }
                                                
                                            }else{
                                                pWpr.type = 'C';
                                                cr.status = 'New Value';
                                                //hasAdd = true;
                                                //pWpr.changedInfo = getChangesInfo(pWpr.changedInfo, pConDetail.Name + ' : Add \n');
                                                contDetail.type = 'N'; 
                                            }
                                            if(String.isNotBlank(cr.status)) pwpr.changeResult.detailChanges.add(cr);                                    
                                            pwpr.contentDetails.add(contDetail);
                                            recCount++; 
                                        }
                                        
                                       /* if(removedRecMap.keySet().size() > 0){
                                            pWpr.removedContentDetails = String.join(new List<String>(removedRecMap.values()), ', ');
                                            hasRemove = true;
                                            //pWpr.changedInfo = getChangesInfo(pWpr.changedInfo, 'Removed: \n' + pWpr.removedContentDetails +' \n');
                                        }*/
                                        if(removedDetailRecMap.keySet().size() > 0){
                                            //getRemovals
                                             pwpr.changeResult.detailChanges.addAll(getDetailResult(removedDetailRecMap.values(),'Old Value'));
                                        }
                                    }else if(contentIdDetailsMap != null && !contentIdDetailsMap.containsKey(pCon.Id) && oldPLDetailsList != null && oldPLDetailsList.size() > 0){
                                        //getRemovals
                                        System.debug('no content details');
                                        //hasRemove = true;
                                        pWpr.type = pWpr.type == 'S' ? 'C' : pWpr.type;
                                        pwpr.changeResult.detailChanges.addAll(getDetailResult(oldPLDetailsList,'Old Value'));
                                    }
                                    
                                   /* if(String.isNotBlank(UpdatedData)){
                                        pWpr.changedInfo += '<b> The following details have been updated : </b><br/>';
                                        pWpr.changedInfo += UpdatedData;
                                    }
                                    if(hasAdd){
                                        pWpr.changedInfo += '<br/><b> The detail(s) have been added</b><br/>';
                                    }
                                    if(hasRemove){
                                        pWpr.changedInfo += '<br/><b> The detail(s) have been removed</b><br/>';
                                    }*/
                                    //--compare content details ends------
                                }
                                else
                                {
                                    pWpr.type = 'N'; //New
                                    
                                    // content details
                                    if(contentIdDetailsMap != null && contentIdDetailsMap.containsKey(pCon.Id)){
                                        //pwpr.changeResult.detailChanges.addAll(getDetailResult(contentIdDetailsMap.get(pCon.Id),'Add'));
                                        for(Placement_Content_Detail__c pConDetail : contentIdDetailsMap.get(pCon.Id)){
                                            PLContentDetailWpr contDetail = new PLContentDetailWpr();
                                            contDetail.pConDetail = pConDetail;
                                            contDetail.type = 'N';
                                            //pWpr.changedInfo = getChangesInfo(pWpr.changedInfo, pConDetail.Name + ' : Add \n');
                                            pwpr.contentDetails.add(contDetail);
                                        }
                                    }
                                }
                            }
                            else
                            {
                                pWpr.type = 'N'; //New
                                
                            }
                        }else{
                            // content details
                            if(contentIdDetailsMap != null && contentIdDetailsMap.containsKey(pCon.Id)){
                                for(Placement_Content_Detail__c pConDetail : contentIdDetailsMap.get(pCon.Id)){
                                    PLContentDetailWpr contDetail = new PLContentDetailWpr();
                                    contDetail.pConDetail = pConDetail;
                                    contDetail.type = '';
                                    pwpr.contentDetails.add(contDetail);
                                }
                            }
                        }
                    }
                    else
                    {
                        if(i > 0) pWpr.type = 'NA'; //No Placement Library
                    }
                    
                    pWpr.plcContent = pCon;
                    //fWpr.list_plcContentWpr.add(pWpr);
                    if(pCon.S_No__c != null){
                        if(!fWpr.plcContentMap.containsKey(Integer.valueOf(pCon.S_No__c))){ fWpr.plcContentMap.put(Integer.valueOf(pCon.S_No__c),new List<plcContentWpr>()); }
                        fWpr.plcContentMap.get(Integer.valueOf(pCon.S_No__c)).add(pWpr);
                    }
                    
                }
                
                //add content removals
                if(i > 0){
                    System.debug('comparedPreviousContentDetails----'+comparedPreviousContentDetails);
                    for(plcContentWpr plWr : list_pLayoutWpr[i-1].list_plcContentWpr){
                        Placement_Content__c plcContent = plWr.plcContent;
                        String abTestName = String.isNotBlank(plcContent.AB_Test_Name__c) ? plcContent.AB_Test_Name__c : '';
                        if(plcContent.S_No__c != null && plWr.type != 'R' && !comparedPreviousContentDetails.contains(plcContent.Placement_Library__c+'-'+plcContent.Type__c + '-' + abTestName)){
                            plcContentWpr pWprRemoved = new plcContentWpr(); 
                            pWprRemoved.Type = 'R';
                            pWprRemoved.plcContent = plcContent;
                            //fWpr.list_plcContentWpr.add(pWprRemoved);
                            if(!fWpr.plcContentMap.containsKey(Integer.valueOf(plcContent.S_No__c))){ fWpr.plcContentMap.put(Integer.valueOf(plcContent.S_No__c),new List<plcContentWpr>()); }
                            fWpr.plcContentMap.get(Integer.valueOf(plcContent.S_No__c)).add(pWprRemoved);
                        }
                    }
                    
                }
                
                if(fWpr.plcContentMap.size() > 0){
                    List<Integer> sNoList = new List<Integer>(fWpr.plcContentMap.keySet());
                    sNoList.sort();    
                    for(Integer sno : sNoList){
                        fWpr.list_plcContentWpr.addAll(fWpr.plcContentMap.get(sno));
                    }
                }
                
                list_pLayoutWpr.add(fWpr);
                i++;
            }
        }else{
            throw new AuraException('No Placements Found!');
        }
        for(Integer j = 1 ; j < list_pLayoutWpr.size() ; j++)
        {
            String missingLibraires = '';
            for(String pId : list_pLayoutWpr[j-1].set_PlcLaibraryIds)
            {
                if(!list_pLayoutWpr[j].set_PlcLaibraryIds.Contains(pId))
                {
                    missingLibraires = missingLibraires+map_PreviousPlayLibraries.get(list_pLayoutWpr[j-1].plcLayout.Id+'-'+pId).Placement_Library__r.Name+';';
                }
            }
            if(missingLibraires != '') missingLibraires = missingLibraires.removeEnd(';');
            list_pLayoutWpr[j].removedLibriaries = missingLibraires;
        }
        fnlWpr.list_pLayoutWpr = list_pLayoutWpr;
        return fnlWpr;
    }
    
    private static CompareUpdateResult getUpdateResult(String field, String newValue, String oldValue){
        CompareUpdateResult cr = new CompareUpdateResult();
        cr.field = field;
        cr.newValue = String.isNotBlank(newValue) ? newValue : '';
        cr.oldValue = String.isNotBlank(oldValue) ? oldValue : '';
        return cr;
    }
    
    private static List<ComparedResult> getDetailResult(List<Placement_Content_Detail__c> details, String status){
        List<ComparedResult> crList = new List<ComparedResult>();
        for(Placement_Content_Detail__c pConDetail : details){
            ComparedResult cr = new ComparedResult();
            String copy = String.isNotBlank(pConDetail.Copy__c) ? pConDetail.Copy__c : '';
            String url = String.isNotBlank(pConDetail.Link_Text__c) ? pConDetail.Link_Text__c : '';
            cr.name = copy + ' ~~ ' + url;
            cr.status = status;
            crList.add(cr);
        }
        return crList; 
    }
    
    
    private static String getChangesInfo(String changesInfo, String newChange){
        changesInfo += changesInfo.contains('Detail Changes :') ? '' : 'Detail Changes : \n ';
        changesInfo += newChange;
        return changesInfo;
    }
    
    public class finalWpr
    {
        @AuraEnabled public Set<String> set_FieldsToDisplay{get;set;}
        @AuraEnabled public List<String> contDetailFields;
        @AuraEnabled public List<pLayoutWpr> list_pLayoutWpr{get;set;}
        public finalWpr()
        {
            set_FieldsToDisplay = new Set<String>();
            list_pLayoutWpr = new List<pLayoutWpr>();
        }
    }
    public class pLayoutWpr
    {
        @AuraEnabled public String removedLibriaries{get;set;}
        @AuraEnabled public Set<String> set_PlcLaibraryIds{get;set;}
        @AuraEnabled public Placement_Layout__c plcLayout{get;set;}
        @AuraEnabled public List<plcContentWpr> list_plcContentWpr{get;set;}
        @AuraEnabled public Map<Integer,List<plcContentWpr>> plcContentMap{get;set;}
        public pLayoutWpr()
        {
            removedLibriaries = '';
            plcLayout = new Placement_Layout__c();
            set_PlcLaibraryIds = new Set<String>();
            list_plcContentWpr = new List<plcContentWpr>();
            plcContentMap = new Map<Integer,List<plcContentWpr>>();
        }
    }
    public class plcContentWpr
    {
        @AuraEnabled public String type{get;set;}
        @AuraEnabled public String removedContentDetails{get;set;}
        @AuraEnabled public Placement_Content__c plcContent{get;set;}
        @AuraEnabled public String changedFields;
        @AuraEnabled public String changedInfo;
        @AuraEnabled public ComparedResult changeResult;
        @AuraEnabled public List<PLContentDetailWpr> contentDetails{get;set;}
        public plcContentWpr()
        {
            type = '';
            removedContentDetails = '';
            plcContent = new Placement_Content__c();
            changedFields = '';
            changedInfo = '';
            contentDetails = new List<PLContentDetailWpr>();
            changeResult = new ComparedResult();
        }
    }
    
    public class PLContentDetailWpr{
        @AuraEnabled public String type;
        @AuraEnabled public Placement_Content_Detail__c pConDetail;
        @AuraEnabled public String changedFields;
        
        public PLContentDetailWpr(){
            pConDetail = new Placement_Content_Detail__c();
        }
    }
    
    public class AuraResponse {
        @AuraEnabled
        public Boolean isSuccess;
        
        @AuraEnabled
        public String message;
        
        @AuraEnabled
        public Object response;
        
        public AuraResponse(Boolean isSuccess, String message, Object response) {
            this.isSuccess = isSuccess;
            this.message = message;
            this.response = response;
        }
    }
    
    public class SelectOption implements comparable {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public Object additionalParameter;
        
        public SelectOption(String label, String value) {
            this.label = label;
            this.value = value;
        }
        
        public SelectOption(String label, String value, Object additionalParameter) {
            this.label = label;
            this.value = value;
            this.additionalParameter = additionalParameter;
        }
        
        // Implement the compareTo() method
        public Integer compareTo(Object compareTo) {
            SelectOption compareToOption = (SelectOption)compareTo;
            if (label == compareToOption.label) return 0;
            if (label > compareToOption.label) return 1;
            return -1;        
        }
    }
    
    public class ComparedResult{
        @AuraEnabled public String name;
        @AuraEnabled public String status;
        @AuraEnabled public List<CompareUpdateResult> updateResult;
        @AuraEnabled public List<ComparedResult> detailChanges;
    }
    
    public class CompareUpdateResult{
        @AuraEnabled public String field;
        @AuraEnabled public String newValue;
        @AuraEnabled public String oldValue;
        
    }
    
}