public class DGTL_PlacementContentTrgHandler 
{  
    /* 
     *  This method is used to a create Record in
     *  Placement_Content_History and DGTL_Task__c onchange of any field value in Placement_Content
     */
    public static void createContentHistoryAndTasks (List<Placement_Content__c> list_PlcConNew,Map<Id,Placement_Content__c> map_PlcConOld){
        List<Placement_Content_History__c> list_PlcContHistory = new List<Placement_Content_History__c>();
        list<string> lst_ContentFields = new list<string>();
        list<string> list_PlcContHistFields = new list<string>();
        list<string> lst_ChangedFields;
        
        // added variables for creating tasks
        List<string> List_Brands = DGTL_DataAccessor.getPicklistValues('Placement_Layout__c', 'Brands__c');
        map<String,list<DGTL_Access_Management__c>> map_AccessManagement = DGTL_PlacementContentServices.getAccessManagementMap(List_Brands,'Placement_Content__c');
        list<DGTL_Task__c> lst_CreateTask = new list<DGTL_Task__c>();
        map<string, list<string>> map_ChangedFld = new map<string, list<string>>(); //End
       
        lst_ContentFields = DGTL_DataAccessor.getHistoryTrackingFields('Placement_Content__c');
        list_PlcContHistFields = DGTL_DataAccessor.getAllFieldApi('Placement_Content_History__c');
        
        for(Placement_Content__c pCon : list_PlcConNew)
        {
            Placement_Content_History__c plcHisRec = new Placement_Content_History__c(Placement_Content__c=pCon.Id);
            boolean boo_Ischanged = false;
            map<string, string> map_UpdFields = new map<string, string>();
            
            // for every field in Placement_Content__c
            for(String fieldApi : lst_ContentFields)
            {
                 String fieldName = fieldApi.toLowerCase();
                // check if the field is available in Placement_Content_History__c and Assign value to it
                if(list_PlcContHistFields.contains(fieldName)){
                    plcHisRec.put(fieldApi,map_PlcConOld.get(pCon.Id).get(fieldApi)); 
                    
                    // if the particular 'field' value is changed make the field_change__c field true
                    if(pCon.get(fieldApi) != map_PlcConOld.get(pCon.Id).get(fieldApi))
                    {   
                        if(!map_ChangedFld.containsKey(pCon.id)){
                            map_ChangedFld.put(pCon.id, new list<string>());
                        }
                        map_ChangedFld.get(pCon.id).add(fieldApi);
                        
                        String changeField = fieldApi.substringBefore('__c')+'_Change__c'; //build change__c field API for the field
                        plcHisRec.put(changeField,true); 
                        boo_Ischanged = true;
                    }
                }
            }
            
            // add record to a list
            if(boo_Ischanged) list_PlcContHistory.add(plcHisRec);
            
            // code to create tasks starts
            if(pCon.Type__c != 'Escalation' && pCon.Formula_Layout_Type__c =='Layout'){
                if(boo_Ischanged && map_AccessManagement.size() != null && map_AccessManagement.get(pCon.Brand__c).size() > 0){
                    // iterate over all the access management for the current placement content brand
                    for(DGTL_Access_Management__c eachAc : map_AccessManagement.get(pCon.Brand__c)) {	string str_Fields = '';
                        for(string changedFld : map_ChangedFld.get(pCon.Id)){
                            if(eachAc.Read_Only_Fields__c.contains(changedFld)) str_Fields += changedFld +',';
                        }
                        if(str_Fields != '' ) map_UpdFields.put(eachAc.Team__c +'-'+ eachAc.brands__c , str_Fields);
                    }
                }
            }
            
            Id TaskRecordTypeId = Schema.SObjectType.DGTL_Task__c.getRecordTypeInfosByName().get('OnChange').getRecordTypeId();
            if(map_UpdFields.size() > 0 ) {
                for(string str : map_UpdFields.keyset()) {	string str_new = str.substringBefore('-');
                    lst_CreateTask.add(new DGTL_Task__c(Description__c = map_UpdFields.get(str).removeEnd(','),
                                                        Placement_Content__c =pCon.id,DGTL_TaskOwner__c = str_new,
                                                        Type__c = 'Automatic',recordTypeId = TaskRecordTypeId));
                }
            }
            //code to create tasks ends
        }
        
          // if record list is not empty insert the list
        if(!list_PlcContHistory.isEmpty()) insert list_PlcContHistory;
        
         // Inserting tasks
        if(lst_CreateTask.size() > 0 )  insert lst_CreateTask;

    }
    
      /* 
	   *  This method is used to a create Task Record based on Insert / Deletion of Placement Content 
	   */
    public static void createTask(List<Placement_Content__c> list_pContent , String context){
           // added variables for creating tasks
        List<string> List_Brands = DGTL_DataAccessor.getPicklistValues('Placement_Layout__c', 'Brands__c');
        map<String,list<DGTL_Access_Management__c>> map_AccessManagement = DGTL_PlacementContentServices.getAccessManagementMap(List_Brands,'Placement_Content__c');
        list<DGTL_Task__c> lst_CreateTask = new list<DGTL_Task__c>();
        map<string, list<string>> map_ChangedFld = new map<string, list<string>>();
        map<string, string> map_UpdFields = new map<string, string>();//End
        
        //system.debug('map_PlcCon....'+map_PlcCon);
        for(Placement_Content__c pContent : list_pContent){
            
            if(pContent.Type__c != 'Escalation' && pContent.Formula_Layout_Type__c =='Layout'){
                if(map_AccessManagement.size() != null && map_AccessManagement.get(pContent.Brand__c).size() > 0){
                    // iterate over all the access management for the current placement content brand
                    for(DGTL_Access_Management__c eachAc : map_AccessManagement.get(pContent.Brand__c)) {
                        string str_Fields = '';
                        if(context == 'Insert'){
                            if(eachAc.Read_Only_Fields__c.contains('Content Added')) str_Fields += 'Content Added' ;
                        }/*else if(context == 'Delete'){
                            if(eachAc.Read_Only_Fields__c.contains('Content Deleted')) str_Fields += 'Content Deleted' ;
                        } */
                        if(str_Fields != '' ) map_UpdFields.put(eachAc.Team__c +'-'+ eachAc.brands__c , str_Fields);
                    }
                }
            }
            
            Id TaskRecordTypeId = Schema.SObjectType.DGTL_Task__c.getRecordTypeInfosByName().get('OnChange').getRecordTypeId();
            if(map_UpdFields.size() > 0 ) {
                for(string str : map_UpdFields.keyset()) { string str_new = str.substringBefore('-');
                    lst_CreateTask.add(new DGTL_Task__c(Description__c = map_UpdFields.get(str).removeEnd(','),
                                                        Placement_Content__c = pContent.id, DGTL_TaskOwner__c = str_new,
                                                        Type__c = 'Automatic', Object_Type__c ='Placement Content', recordTypeId = TaskRecordTypeId));
                }
            } 
        }
        // if record list is not empty insert the list
        if(!lst_CreateTask.isEmpty()) insert lst_CreateTask;
    }
    
     public static void createInsertTask(List<Placement_Content__c> list_pContent){
         createTask(list_pContent, 'Insert');
         createHistory(list_pContent, 'Insert');
    }
    
    
   /* public static void createDeteleTask(List<Placement_Content__c> list_pContent){
        createTask(list_pContent,'Delete');
    } */
    
    // Creation of History Tracking Records for History and Onchange RecordType on every field update
    public static void createHistoryAndOnChange(List<Placement_Content__c> list_PlcConNew,Map<Id,Placement_Content__c> map_PlcConOld){
        List<History_Tracking__c> list_PlcContHistory = new List<History_Tracking__c>();
        Map<String,String> objectFieldsMap = DGTL_DataAccessor.getObjectFieldLabelAndApi('placement_Content__c');
        // added variables for creating tasks
        List<string> List_Brands = DGTL_DataAccessor.getPicklistValues('Placement_Layout__c', 'Brands__c');
        map<String,list<DGTL_Access_Management__c>> map_AccessManagement = getAccessManagementMap(List_Brands,'Placement_Content__c');
        list<History_Tracking__c> lst_CreateTask = new list<History_Tracking__c>();
        map<string, list<string>> map_ChangedFld = new map<string, list<string>>(); //End
        map<String, History_Tracking__c> map_ContentHistory = new  map<String,History_Tracking__c>(); 
        
        Id recordTypeId = Schema.SObjectType.History_Tracking__c.getRecordTypeInfosByName().get('OnChange').getRecordTypeId();
        Id historyRecTypeId = Schema.SObjectType.History_Tracking__c.getRecordTypeInfosByName().get('History Records').getRecordTypeId();
        //--------get the existing records to update the new value
        list<History_Tracking__c> existingRecords = [Select id, name,Brand__c,Category__c,Owner__c,Field_API__c,Field_Name__c,
                                                     LastModifiedById,New_Value__c,Old_Value__c,Object_Name__c,
                                                     Placement_Content__c,Placement_Layout__c,RecordTypeId From 
                                                     History_Tracking__c Where Object_Name__c = 'Placement Content' and
                                                     Placement_Content__c != null and RecordTypeId =:recordTypeId];
        
        for(History_Tracking__c histRec : existingRecords){ // put records into map  - Content - List of Onchange Records
            map_ContentHistory.put(histRec.Placement_Content__c + histRec.Field_API__c + histRec.Owner__c + histRec.Brand__c + histRec.Category__c,histRec);
        }
        
        for(Placement_Content__c pCon : list_PlcConNew)
        {		
                boolean boo_Ischanged = false;
                map<string, string> map_UpdFields = new map<string, string>();
                
                // for every field in Placement_Content__c
                for(String fieldApi : objectFieldsMap.keySet())
                {
                    //fieldApi = fieldApi.toLowerCase();
                    if(pCon.get(fieldApi) != map_PlcConOld.get(pCon.Id).get(fieldApi))
                    {   
                        // creation of hostory Records
                        History_Tracking__c plcHisRec = new History_Tracking__c(Placement_Content__c=pCon.Id,RecordTypeId =historyRecTypeId,
                                                                                Object_Name__c = 'Placement Content' );
                        system.debug('fieldApi...'+fieldApi); system.debug('pCon.get(fieldApi)...'+pCon.get(fieldApi));
                     	system.debug('map_PlcConOld.get(pCon.Id).get(fieldApi)...'+map_PlcConOld.get(pCon.Id).get(fieldApi));
                        plcHisRec.Old_Value__c = String.valueOf(map_PlcConOld.get(pCon.Id).get(fieldApi));
                        plcHisRec.New_Value__c = String.valueOf(pCon.get(fieldApi));
                        plcHisRec.Field_API__c = fieldApi;
                        plcHisRec.Field_Name__c = objectFieldsMap.get(fieldApi);
                        
                        if(!map_ChangedFld.containsKey(pCon.id)){
                            map_ChangedFld.put(pCon.id, new list<string>());
                        }
                        map_ChangedFld.get(pCon.id).add(fieldApi);
                      
                        boo_Ischanged = true;
                          // add record to a list
               			 //if(boo_Ischanged) 
               			 list_PlcContHistory.add(plcHisRec);
                    }
                }
                
              
                
                // code to create OnChange Records starts
                if(pCon.Type__c != 'Escalation' && pCon.Formula_Layout_Type__c =='Layout'){
                if(boo_Ischanged && map_AccessManagement.size() != null && map_AccessManagement.get(pCon.Brand__c).size() > 0){
                    // iterate over all the access management for the current placement content brand
                    for(DGTL_Access_Management__c eachAc : map_AccessManagement.get(pCon.Brand__c)) { string str_Fields = '';
                        String type = String.isNotBlank(pCon.Placement_type__c) ?  pCon.Placement_type__c : '';
                        String mainMessage = String.isNotBlank(pCon.Main_Message__c) ? '  - '+  pCon.Main_Message__c : '';
                        for(string changedFld : map_ChangedFld.get(pCon.Id)){
                            if(eachAc.Read_Only_Fields__c.contains(changedFld)) { //Check whether this field has record in Map
                                //if yes -- Update record
                                if(map_ContentHistory.get(pCon.Id + changedFld+ eachAc.Team__c + eachAc.Brands__c + eachAc.Category__c) != null){
                                    History_Tracking__c histRec = map_ContentHistory.get(pCon.Id + changedFld + eachAc.Team__c + eachAc.Brands__c + eachAc.Category__c);
                                    if(changedFld =='Active__c' && pCon.get(changedFld) == true){
                                        histRec.Field_Name__c = 'Placement Activated';		 histRec.Old_Value__c = type+' <br/>'+mainMessage;
                                    }else if(changedFld =='Active__c' && pCon.get(changedFld) == false){
                                        histRec.Field_Name__c = 'Placement Deleted';  histRec.Old_Value__c = type+' <br/>'+mainMessage;
                                    }else{
                                        histRec.New_Value__c = String.valueOf(pCon.get(histRec.Field_API__c));
                                    }
                                    lst_CreateTask.add(histRec);
                                }
                                else if(pCon.Placement_Page_Type__c != null && ((eachAc.Category__c == null || pCon.Placement_Page_Type__c.ContainsIgnoreCase(eachAc.Category__c)))){//Else insert record
                                   History_Tracking__c historyRec = new History_Tracking__c(RecordTypeId =recordTypeId,Brand__c= eachAc.Brands__c,
                                                                               Category__c = eachAc.Category__c,Owner__c = eachAc.Team__c,Field_Name__c =objectFieldsMap.get(changedFld),
                                                                               Placement_Layout__c = pCon.Placement_Layout__c,Placement_Content__c = pCon.Id,
                                                                               Object_Name__c = 'Placement Content', Field_API__c = changedFld);
                                   /* lst_CreateTask.add(new History_Tracking__c(RecordTypeId =recordTypeId,Brand__c= eachAc.Brands__c,
                                                                               Category__c = eachAc.Category__c,
                                                                               Owner__c = eachAc.Team__c, Field_Name__c =objectFieldsMap.get(changedFld),
                                                                               Placement_Layout__c = pCon.Placement_Layout__c,
                                                                               Placement_Content__c = pCon.Id, Object_Name__c = 'Placement Content',
                                                                               Field_API__c = changedFld,
                                                                               Old_Value__c = String.valueOf(map_PlcConOld.get(pCon.Id).get(changedFld)),
                                                                               New_Value__c = String.valueOf(pCon.get(changedFld))));*/
                                    if(changedFld =='Active__c' && pCon.get(changedFld) == true){
                                        historyRec.Field_Name__c = 'Placement Activated';  historyRec.Old_Value__c = type+' '+mainMessage;
                                    }else if(changedFld =='Active__c' && pCon.get(changedFld) == false){
                                        historyRec.Field_Name__c = 'Placement Deleted';  historyRec.Old_Value__c = type+'  '+mainMessage;
                                    }else{
                                        historyRec.Old_Value__c = String.valueOf(map_PlcConOld.get(pCon.Id).get(changedFld));
                                        historyRec.New_Value__c =  String.valueOf(pCon.get(changedFld));
                                    }
                                    lst_CreateTask.add(historyRec);
                                }
                            }
                        }
                    }
                } // code to create OnChange Records starts
            }
        }
        // updating OnChange Records records
        if(lst_CreateTask.size() > 0 )  upsert lst_CreateTask;
        
        //insert History Records
        if(list_PlcContHistory.size() > 0 ) insert list_PlcContHistory;
    }
   
    
       /* 
	   *  This method is used to a create OnChange Task Record based on Insert / Deletion of Placement Content 
	   */
    public static void createHistory(List<Placement_Content__c> list_pContent , String context){
           // added variables for creating tasks
        List<string> List_Brands = DGTL_DataAccessor.getPicklistValues('Placement_Layout__c', 'Brands__c');
        map<String,list<DGTL_Access_Management__c>> map_AccessManagement = getAccessManagementMap(List_Brands,'Placement_Content__c');
        list<History_Tracking__c> lst_CreateOnchange = new list<History_Tracking__c>();
        map<string, list<string>> map_ChangedFld = new map<string, list<string>>();
        map<string, string> map_UpdFields = new map<string, string>();//End
        
        //system.debug('map_PlcCon....'+map_PlcCon);
        for(Placement_Content__c pContent : list_pContent){
            Id recordTypeId = Schema.SObjectType.History_Tracking__c.getRecordTypeInfosByName().get('OnChange').getRecordTypeId();
            if(pContent.Type__c != 'Escalation' && pContent.Formula_Layout_Type__c =='Layout'){
                if(map_AccessManagement.size() != null && map_AccessManagement.get(pContent.Brand__c).size() > 0){
                    // iterate over all the access management for the current placement content brand
                    for(DGTL_Access_Management__c eachAc : map_AccessManagement.get(pContent.Brand__c)) {
                        string str_Fields = '';
                        String type = String.isNotBlank(pContent.Placement_type__c) ?  pContent.Placement_type__c : '';
                        String mainMessage = String.isNotBlank(pContent.Main_Message__c) ? '  - '+  pContent.Main_Message__c : '';
                        if(context == 'Insert' && (pContent.Placement_Page_Type__c != null && (eachAc.Category__c == null || pContent.Placement_Page_Type__c.ContainsIgnoreCase(eachAc.Category__c)))){
                            if(eachAc.Read_Only_Fields__c.contains('Placement Added')){
                                lst_CreateOnchange.add(new History_Tracking__c(Field_Name__c = 'Placement Added',
                                                                               Placement_Content__c = pContent.Id, Brand__c = pContent.Brand__c,
                                                                               Owner__c = eachAc.Team__c,Category__c = eachAc.Category__c,
                                                                               Placement_Layout__c = pContent.Placement_Layout__c,Object_Name__c ='Placement Content',
                                                                               Old_Value__c = type+' '+mainMessage, recordTypeId = recordTypeId)); 
                            }
                        }
                    }
                }
            }
        }
        // if record list is not empty insert the list
        if(!lst_CreateOnchange.isEmpty()) insert lst_CreateOnchange;
    }
    
    public static void linkKods(){
        Map<Id,Set<Id>> contentIdWithLibraryMap = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> contentIdWithCloneSourceMap = new Map<Id,Set<Id>>();
        List<Placement_KOD__c> plKodList = new List<Placement_KOD__c>();
        
        List<Placement_Content__c> plcList = Trigger.new;
        
        for(Placement_Content__c plc : plcList){
            System.debug('plc.isClone()===='+plc.isClone());
            if(plc.isClone() && plc.getCloneSourceId() != null){
                Id cloneSourceId = String.valueOf(plc.getCloneSourceId());
				if(!contentIdWithCloneSourceMap.containsKey(cloneSourceId)){ contentIdWithCloneSourceMap.put(cloneSourceId, new Set<Id>()); }
                contentIdWithCloneSourceMap.get(cloneSourceId).add(plc.Id);
            }else if(plc.Placement_Library__c != null){
                if(!contentIdWithLibraryMap.containsKey(plc.Placement_Library__c)){ contentIdWithLibraryMap.put(plc.Placement_Library__c, new Set<Id>()); }
                contentIdWithLibraryMap.get(plc.Placement_Library__c).add(plc.Id);
            }
        }
        
        if(contentIdWithCloneSourceMap.size() > 0){
            Set<Id> plcIds = new Set<Id>(contentIdWithCloneSourceMap.keySet());
            for(Placement_KOD__c pKod : [SELECT Placement_Content__c,KOD__c FROM Placement_KOD__c WHERE Placement_Content__c IN:plcIds]){
				for(Id plcId : contentIdWithCloneSourceMap.get(pKod.Placement_Content__c)){
					plKodList.add(new Placement_KOD__c(Placement_Content__c=plcId,KOD__c = pKod.KOD__c));
				}
            }
        }
        
        if(contentIdWithLibraryMap.size() > 0){
            Set<Id> libIds = new Set<Id>(contentIdWithLibraryMap.keySet());
            for(Placement_KOD__c pKod : [SELECT Placement_Library__c,KOD__c FROM Placement_KOD__c WHERE Placement_Library__c IN:libIds]){
                for(Id plcId : contentIdWithLibraryMap.get(pKod.Placement_Library__c)){
                    plKodList.add(new Placement_KOD__c(Placement_Content__c=plcId,KOD__c = pKod.KOD__c ));
                }
            }
        }
        
        if(plKodList.size() > 0) insert plKodList;
        
    }
    
     public static map<String,list<DGTL_Access_Management__c>> getAccessManagementMap(list<string> str_Brand,String str_objectName) {
        map<String,list<DGTL_Access_Management__c>> map_BrandAccessMgmt = New map<String,list<DGTL_Access_Management__c>>();
        list<DGTL_Access_Management__c> list_AccessMgmt = getAccessManagement(str_Brand,str_objectName);
        for(String brand : str_Brand){
            list<DGTL_Access_Management__c> list_BrandAccessMgmt = New list<DGTL_Access_Management__c>();
            for(DGTL_Access_Management__c accessMgmt : list_AccessMgmt){
                if(accessMgmt.Brands__c == brand) list_BrandAccessMgmt.add(accessMgmt);
            }
            map_BrandAccessMgmt.put(brand,list_BrandAccessMgmt);
        }
        return map_BrandAccessMgmt;
    }
    
    public static list<DGTL_Access_Management__c> getAccessManagement(list<string> str_Brand , String str_objectName) {
        id recTypeId =  Schema.SObjectType.DGTL_Access_Management__c.getRecordTypeInfosByName().get('Notification').getRecordTypeId();
        map<String,list<DGTL_Access_Management__c>> map_BrandAccessMgmt = New map<String,list<DGTL_Access_Management__c>>();
        
        list<DGTL_Access_Management__c> list_AccessMgmt = [select name,Team__c,Read_Only_Fields__c,Brands__c,Category__c
                                                           from DGTL_Access_Management__c where Brands__c IN : str_Brand 
                                                           and Read_Only_Fields__c != null AND Object_Name__c =: str_objectName
                                                           AND RecordTypeId =: recTypeId AND Team__c != null];
        for(DGTL_Access_Management__c each : list_AccessMgmt) {
            system.debug(each);
        }
        return list_AccessMgmt;
        
    }
    
    /*
    public static void checkForUpdatesBeforeDueDate(List<Placement_Content__c> list_PlcConNew,Map<Id,Placement_Content__c> map_PlcConOld)
    {
        
        Set<Id> set_PlcLayIds = new Set<Id>();
        for(Placement_Content__c pCon : list_PlcConNew)
        {
           
            if(pCOn.Approval_Status__c != 'Waiting for Approval')
            {
                for(String field : DGTL_Placement_Content_History_Tracking__c.getAll().KeySet())
                {
                    if(pCon.get(field) != map_PlcConOld.get(pCon.Id).get(field))
                    {
                        set_PlcLayIds.add(pCon.Placement_Layout__c);
                        break;
                    }
                }
            }
        }
        if(!set_PlcLayIds.isEmpty())
        {
            Map<Id,Placement_Layout__c> map_PlcLayouts = new Map<Id,Placement_Layout__c>([SELECT Id,Date_Formula__c,Name FROM Placement_Layout__c WHERE Id IN: set_PlcLayIds]);
            for(Placement_Content__c pCon : list_PlcConNew)
            {
                if(pCOn.Approval_Status__c != 'Waiting for Approval')
                {
                    Date cutOffDate = map_PlcLayouts.get(pCon.Placement_Layout__c).Date_Formula__c.addDays(-3);
                    for(String field : DGTL_Placement_Content_History_Tracking__c.getAll().KeySet())
                    {
                        if(pCon.get(field) != map_PlcConOld.get(pCon.Id).get(field) && System.Today() > cutOffDate && System.Today() < map_PlcLayouts.get(pCon.Placement_Layout__c).Date_Formula__c)
                        {
                            pCOn.Approval_Status__c = 'Waiting for Approval';
                            break;
                        }
                    }
                }
                
            }
        }
    }
	*/
    
    /* 
      * Method is used to create tasks for digital when fields are changed in placement content
      */
        
    /* public static void checkForUpdates(List<Placement_Content__c> list_PlcConNew,Map<Id,Placement_Content__c> map_PlcConOld)
    {   
        List<string> List_Brands = new list<string>{'PINK', 'Swim', 'VS', 'Beauty'};
        list<DGTL_Access_Management__c> lst_AccessManagement = DGTL_PlacementContentServices.getAccessManagement(List_Brands,'Placement_Content__c');
        list<DGTL_Task__c> lst_CreateTask = new list<DGTL_Task__c>();
     
        for(Placement_Content__c pCon : list_PlcConNew)
        {
            map<string, string> lst_ChangedFields = new map<string,string>();
            map<string, string> map_UpdFields = new map<string, string>();
            
            // Comparing changed fields
            
            for(DGTL_Placement_Content_History_Tracking__c his : DGTL_Placement_Content_History_Tracking__c.getAll().values())
            {
                String field = his.name;
                if(pCon.get(field) != map_PlcConOld.get(pCon.Id).get(field))
                {  
                    lst_ChangedFields.put(field,his.label__c);
                }

            }
            
            //Create Task Block
            if(lst_ChangedFields.size() > 0 && lst_AccessManagement.size() > 0) {                
                for(DGTL_Access_Management__c eachAc : lst_AccessManagement) {
                     
                    string str_Fields = '';
                    if(eachAc.Read_Only_Fields__c != null && pCon.Brand__c == eachAc.brands__c ) {
                         
                        for(string str : eachAc.Read_Only_Fields__c.split(';')){
                          
                            if(lst_ChangedFields.keyset().contains(str)) str_Fields += lst_ChangedFields.get(str) +',';
                        }
                    } 

                    if(str_Fields != '' ) map_UpdFields.put(eachAc.Team__c +'-'+ eachAc.brands__c , str_Fields);
                    
                }

                if(map_UpdFields.size() > 0 ) {
                    for(string str : map_UpdFields.keyset()) {
                        Id TaskRecordTypeId = Schema.SObjectType.DGTL_Task__c.getRecordTypeInfosByName().get('OnChange').getRecordTypeId(); 
                        string str_new = str.substringBefore('-');
                        lst_CreateTask.add(new DGTL_Task__c(Description__c = map_UpdFields.get(str).removeEnd(','),
                                                            Placement_Content__c =pCon.id,
                                                            DGTL_TaskOwner__c = str_new,
                                                            recordTypeId = TaskRecordTypeId,
                                                            Type__c = 'Automatic'));
                    }
                }
                
            }
        }
         // Inserting tasks
        if(lst_CreateTask.size() > 0 ) insert lst_CreateTask;
    } */
    
   
    
}