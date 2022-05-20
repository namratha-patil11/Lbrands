public class DGTL_PlacementContentDetTrgServices {
    
    /*  OLD Code
     *  Histrory Records Are Created by This block
	 *  This method is used to a create Record in Placement_Content_History onchange of any field value in Placement_Content
	 */
    public static void createContentHistory (List<Placement_Content_Detail__c> list_PlcConDetNew,Map<Id,Placement_Content_Detail__c> map_PlcConDetOld){
        List<Placement_Content_Detail_History__c> list_PlcContDetHistory = new List<Placement_Content_Detail_History__c>();
        list<string> lst_ContentDetFields = new list<string>();
        list<string> list_PlcContDetHistFields = new list<string>();
        lst_ContentDetFields = DGTL_DataAccessor.getHistoryTrackingFields('Placement_Content_Detail__c');
        list_PlcContDetHistFields = DGTL_DataAccessor.getAllFieldApi('Placement_Content_Detail_History__c');
        
        // added variables for creating tasks
        List<string> List_Brands = DGTL_DataAccessor.getPicklistValues('Placement_Layout__c', 'Brands__c');
        map<String,list<DGTL_Access_Management__c>> map_AccessManagement = DGTL_PlacementContentServices.getAccessManagementMap(List_Brands,'Placement_Content_Detail__c');
        list<DGTL_Task__c> lst_CreateTask = new list<DGTL_Task__c>();
        map<string, list<string>> map_ChangedFld = new map<string, list<string>>();
        map<string, string> map_UpdFields = new map<string, string>();//End
        
        
        for(Placement_Content_Detail__c pConDet : list_PlcConDetNew)
        {   
            Placement_Content_Detail_History__c plcHisRec = new Placement_Content_Detail_History__c(Placement_Content_Detail__c=pConDet.Id);
            boolean boo_Ischanged = false;
            
            
            // for every field in Placement_Content__c
            for(String fieldApi : lst_ContentDetFields)
            {   
                String fieldName = fieldApi.toLowerCase();
                // check if the field is available in Placement_Content_Detail_History__c and Assign value to it
                if(list_PlcContDetHistFields.contains(fieldName)){
                    plcHisRec.put(fieldApi,map_PlcConDetOld.get(pConDet.Id).get(fieldApi)); 
                    
                    // if the particular 'field' value is changed make the field_change__c field true
                    if(pConDet.get(fieldApi) != map_PlcConDetOld.get(pConDet.Id).get(fieldApi))
                    {   //--- added for task
                        if(!map_ChangedFld.containsKey(pConDet.id)){
                            map_ChangedFld.put(pConDet.id, new list<string>());
                        }
                        map_ChangedFld.get(pConDet.id).add(fieldApi); //--- added for task
                        
                        String changeField = fieldApi.substringBefore('__c')+'_Change__c'; //build change__c field API for the field
                        plcHisRec.put(changeField,true); 
                        boo_Ischanged = true;
                    }
                }
            }
            // add record to a list
            if(boo_Ischanged) list_PlcContDetHistory.add(plcHisRec);
            
            // code to create tasks starts-----------------------------
            if(pConDet.Type__c != 'Escalation' && pConDet.Placement_Content__c != null && pConDet.Formula_Layout_Type__c =='Layout'){
                system.debug('in task creation loop----'+map_AccessManagement+'--booloean----'+boo_Ischanged);
                if(boo_Ischanged && map_AccessManagement.size() != null && map_AccessManagement.get(pConDet.Brand__c).size() > 0){
                    system.debug('in task creation loop----');
                    // iterate over all the access management for the current placement content brand
                    for(DGTL_Access_Management__c eachAc : map_AccessManagement.get(pConDet.Brand__c)) {
                        string str_Fields = '';
                        for(string changedFld : map_ChangedFld.get(pConDet.Id)){
                            if(eachAc.Read_Only_Fields__c.contains(changedFld)) str_Fields += changedFld +',';
                        }
                        if(str_Fields != '' ) map_UpdFields.put(eachAc.Team__c +'-'+ eachAc.brands__c , str_Fields);
                    }
                }  
            }
            
            Id TaskRecordTypeId = Schema.SObjectType.DGTL_Task__c.getRecordTypeInfosByName().get('OnChange').getRecordTypeId();
            if(map_UpdFields.size() > 0 ) {
                for(string str : map_UpdFields.keyset()) {
                    string str_new = str.substringBefore('-');
                    lst_CreateTask.add(new DGTL_Task__c(Description__c = map_UpdFields.get(str).removeEnd(','),
                                                        Placement_Content__c = pConDet.Placement_Content__c,
                                                        DGTL_TaskOwner__c = str_new,
                                                        Type__c = 'Automatic',
                                                        Object_Type__c ='Placement Content Detail',
                                                        recordTypeId = TaskRecordTypeId));
                }
            }
            //code to create tasks ends -----------------------------------
        }
        // if record list is not empty insert the list
        if(!list_PlcContDetHistory.isEmpty()) insert list_PlcContDetHistory;
        
        // if record list is not empty insert the list
       // if(!lst_CreateTask.isEmpty()) insert lst_CreateTask;
    }
    
    /* 
	 *  This method is used to a create Task Record based on Insert / Deletion of Placement Content Detail --- No Longer Used
	 */
   /* public static void createTask(Map<Id,Placement_Content_Detail__c> map_PlcConDet , String context){
        // added variables for creating tasks
        List<string> List_Brands = DGTL_DataAccessor.getPicklistValues('Placement_Layout__c', 'Brands__c');
        map<String,list<DGTL_Access_Management__c>> map_AccessManagement = DGTL_PlacementContentServices.getAccessManagementMap(List_Brands,'Placement_Content_Detail__c');
        list<DGTL_Task__c> lst_CreateTask = new list<DGTL_Task__c>();
        map<string, list<string>> map_ChangedFld = new map<string, list<string>>();
        map<string, string> map_UpdFields = new map<string, string>();//End
        
        for(String oldId : map_PlcConDet.keyset()){
            
            Placement_Content_Detail__c pConDet = new Placement_Content_Detail__c();
            if(map_PlcConDet.get(oldId) != null)  pConDet = map_PlcConDet.get(oldId);
            
            if(pConDet.Placement_Content__c != null){
                
                if(pConDet.Type__c != 'Escalation' && pConDet.Formula_Layout_Type__c =='Layout'){
                    if(map_AccessManagement.size() != null && map_AccessManagement.get(pConDet.Brand__c).size() > 0){
                        // iterate over all the access management for the current placement content brand
                        for(DGTL_Access_Management__c eachAc : map_AccessManagement.get(pConDet.Brand__c)) {
                            string str_Fields = '';
                            if(context == 'Insert'){
                                if(eachAc.Read_Only_Fields__c.contains('Detail Added')) str_Fields += 'Detail Added' ;
                            }else if(context == 'Delete'){
                                if(eachAc.Read_Only_Fields__c.contains('Detail Deleted')) str_Fields += 'Detail Deleted' ;
                            }
                            
                            if(str_Fields != '' ) map_UpdFields.put(eachAc.Team__c +'-'+ eachAc.brands__c , str_Fields);
                        }
                    }
                }
                
                Id TaskRecordTypeId = Schema.SObjectType.DGTL_Task__c.getRecordTypeInfosByName().get('OnChange').getRecordTypeId();
                if(map_UpdFields.size() > 0 ) {
                    for(string str : map_UpdFields.keyset()) {
                        string str_new = str.substringBefore('-');
                        lst_CreateTask.add(new DGTL_Task__c(Description__c = map_UpdFields.get(str).removeEnd(','),
                                                            Placement_Content__c = pConDet.Placement_Content__c,
                                                            DGTL_TaskOwner__c = str_new,
                                                            Type__c = 'Automatic',
                                                            Object_Type__c ='Placement Content Detail',
                                                            recordTypeId = TaskRecordTypeId));
                    }
                } 
            }
        }
        // if record list is not empty insert the list
        if(!lst_CreateTask.isEmpty()) insert lst_CreateTask;
    }*/
    
   /* public static void createDeleteTask(Map<Id,Placement_Content_Detail__c> map_PlcConDetOld){
        //createTask(map_PlcConDetOld,'Delete');
        //createHistory(map_PlcConDetOld,'Delete');
    } */
    
    public static void createDeleteHistoryTask (Map<Id,Placement_Content_Detail__c> map_PlcConDetOld){
        // before delete
        createHistory(map_PlcConDetOld,'Delete');
    }
    
    public static void createInsertTask(Map<Id,Placement_Content_Detail__c> map_PlcConDetNew){
        //createTask(map_PlcConDetNew,'Insert');
        createHistory(map_PlcConDetNew,'Insert');
    }
    
    /* 
     *  DO NOT Remove THIS - Histrory Records and OnChange Notification Records Are Created by This block 
	 *  This method is used in Creation of History Tracking Records for History and Onchange RecordType on every field update
	 */
    public static void createHistoryAndOnChange(List<Placement_Content_Detail__c> list_PlcConDetNew,Map<Id,Placement_Content_Detail__c> map_PlcConOld){
        List<History_Tracking__c> list_PlcContHistory = new List<History_Tracking__c>();
        Map<String,String> objectFieldsMap = DGTL_DataAccessor.getObjectFieldLabelAndApi('Placement_Content_Detail__c');
        // added variables for creating tasks
        List<string> List_Brands = DGTL_DataAccessor.getPicklistValues('Placement_Layout__c', 'Brands__c');
        map<String,list<DGTL_Access_Management__c>> map_AccessManagement = DGTL_PlacementContentTrgHandler.getAccessManagementMap(List_Brands,'Placement_Content_Detail__c');
        list<History_Tracking__c> lst_CreateTask = new list<History_Tracking__c>();
        map<string, list<string>> map_ChangedFld = new map<string, list<string>>(); //End
        map<String, History_Tracking__c> map_ContentHistory = new  map<String,History_Tracking__c>(); 
        
        Id recordTypeId = Schema.SObjectType.History_Tracking__c.getRecordTypeInfosByName().get('OnChange').getRecordTypeId();
        Id historyRecTypeId = Schema.SObjectType.History_Tracking__c.getRecordTypeInfosByName().get('History Records').getRecordTypeId();
        //--------get the existing records to update the new value
        list<History_Tracking__c> existingRecords = [Select id, name,Brand__c,Category__c,Owner__c,Field_API__c,Field_Name__c,
                                                     LastModifiedById,New_Value__c,Old_Value__c,Object_Name__c,Placement_Content_Detail__c,
                                                     Placement_Content__c,Placement_Layout__c,RecordTypeId From 
                                                     History_Tracking__c Where Object_Name__c = 'Placement Content Detail' and
                                                     Placement_Content_Detail__c != null and RecordTypeId =:recordTypeId];
        
        for(History_Tracking__c histRec : existingRecords){ // put records into map  - Content - List of Onchange Records
            map_ContentHistory.put(histRec.Placement_Content_Detail__c + histRec.Field_API__c + histRec.Owner__c + histRec.Brand__c + histRec.Category__c,histRec);
        }
        system.debug(map_ContentHistory);
        for(Placement_Content_Detail__c pCon : list_PlcConDetNew)
        {		
            boolean boo_Ischanged = false;
            map<string, string> map_UpdFields = new map<string, string>();
            
            // for every field in Placement_Content_Detail__c
            for(String fieldApi : objectFieldsMap.keySet())
            {
                //fieldApi = fieldApi.toLowerCase();
                if(pCon.get(fieldApi) != map_PlcConOld.get(pCon.Id).get(fieldApi))
                {   // creation of history Records
                    History_Tracking__c plcHisRec = new History_Tracking__c(Placement_Content_Detail__c = pCon.Id,
                                                                            Placement_Content__c= pCon.Placement_Content__c,
                                                                            RecordTypeId = historyRecTypeId,
                                                                            Object_Name__c = 'Placement Content Detail' );
                    
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
            
            // add record to a list
           // if(boo_Ischanged) list_PlcContHistory.add(plcHisRec);
            
            // code to create OnChange Records starts
            if(pCon.Type__c != 'Escalation' && pCon.Placement_Content__c != null && 
               pCon.Formula_Layout_Type__c =='Layout'){System.debug('Inside -- onChange Loop--');
                if(boo_Ischanged && map_AccessManagement.size() != null && map_AccessManagement.get(pCon.Brand__c).size() > 0){
                    // iterate over all the access management for the current placement content brand
                    for(DGTL_Access_Management__c eachAc : map_AccessManagement.get(pCon.Brand__c)) { string str_Fields = '';
                        for(string changedFld : map_ChangedFld.get(pCon.Id)){
                            if(eachAc.Read_Only_Fields__c.contains(changedFld)) { //Check whether this field has record in Map
                                //if yes -- Update record
                                if(map_ContentHistory.get(pCon.Id + changedFld + eachAc.Team__c + eachAc.Brands__c + eachAc.Category__c) != null /* && eachAc.Category__c == null || (pCon.Page_Type__c.ContainsIgnoreCase(eachAc.Category__c)) */){
                                    History_Tracking__c histRec = map_ContentHistory.get(pCon.Id + changedFld + eachAc.Team__c + eachAc.Brands__c + eachAc.Category__c);
                                    histRec.New_Value__c = String.valueOf(pCon.get(histRec.Field_API__c));
                                    lst_CreateTask.add(histRec);
                                }
                                else if(pCon.Page_Type__c != null && eachAc.Category__c == null ||  pCon.Page_Type__c.ContainsIgnoreCase(eachAc.Category__c)){//Else insert record
                                    lst_CreateTask.add(new History_Tracking__c(RecordTypeId =recordTypeId,Brand__c= eachAc.Brands__c,
                                                                               Owner__c = eachAc.Team__c,Field_Name__c =objectFieldsMap.get(changedFld),
                                                                               Category__c = eachAc.Category__c, Placement_Layout__c = pCon.Placement_Layout__c,
                                                                               Placement_Content_Detail__c = pCon.Id,Placement_Content__c = pCon.Placement_Content__c, 
                                                                               Field_API__c = changedFld,Old_Value__c = String.valueOf(map_PlcConOld.get(pCon.Id).get(changedFld)),
                                                                               Object_Name__c = 'Placement Content Detail',New_Value__c = String.valueOf(pCon.get(changedFld))));
                                }
                            }
                        }
                    }
                } // code to create OnChange Records starts
            }
        }system.debug(lst_CreateTask);
        // updating OnChange Records records
        if(lst_CreateTask.size() > 0 )  upsert lst_CreateTask;
        
        //insert History Records
        if(list_PlcContHistory.size() > 0 ) insert list_PlcContHistory;
    }
    
    
    /* 
     *  DO NOT Remove THIS - Histrory Records and OnChange Notification Records
	 *  This method is used in Creation of History Tracking Records for Onchange RecordType on Insert / Deletion
	 */
   
    public static void createHistory(Map<Id,Placement_Content_Detail__c> map_PlcConDet , String context){
        // added variables for creating tasks
        List<string> List_Brands = DGTL_DataAccessor.getPicklistValues('Placement_Layout__c', 'Brands__c');
        map<String,list<DGTL_Access_Management__c>> map_AccessManagement = DGTL_PlacementContentTrgHandler.getAccessManagementMap(List_Brands,'Placement_Content_Detail__c');
        list<History_Tracking__c> lst_CreateOnchange = new list<History_Tracking__c>();
        map<string, list<string>> map_ChangedFld = new map<string, list<string>>();
        map<string, string> map_UpdFields = new map<string, string>();//End
        
        for(String oldId : map_PlcConDet.keyset()){
            
            Placement_Content_Detail__c pConDet = new Placement_Content_Detail__c();
            if(map_PlcConDet.get(oldId) != null)  pConDet = map_PlcConDet.get(oldId);
            
            if(pConDet.Placement_Content__c != null){
                Id recordTypeId = Schema.SObjectType.History_Tracking__c.getRecordTypeInfosByName().get('OnChange').getRecordTypeId();
                if(pConDet.Type__c != 'Escalation' && pConDet.Formula_Layout_Type__c =='Layout'){
                    if(map_AccessManagement.size() != null && map_AccessManagement.get(pConDet.Brand__c).size() > 0){
                        // iterate over all the access management for the current placement content brand
                        for(DGTL_Access_Management__c eachAc : map_AccessManagement.get(pConDet.Brand__c)) { string str_Fields = '';
                            String URL = String.isNotBlank(pConDet.Link_Text__c) ? 'URL - '+  pConDet.Link_Text__c : '';
                            String Copy = String.isNotBlank(pConDet.Copy__c) ? 'COPY - '+  pConDet.Copy__c : '';
                            if(context == 'Insert' && (pConDet.Page_Type__c != null  && eachAc.Category__c == null || pConDet.Page_Type__c.ContainsIgnoreCase(eachAc.Category__c))){
                                if(eachAc.Read_Only_Fields__c.contains('Placement Detail Added')){
                                    lst_CreateOnchange.add(new History_Tracking__c(Field_Name__c = 'Placement Detail Added', Brand__c = pConDet.Brand__c,
                                                                               Placement_Content__c = pConDet.Placement_Content__c,Placement_Content_Detail__c = pConDet.Id,
                                                                               Old_Value__c = URL+'<br/>'+Copy,Owner__c = eachAc.Team__c,
                                                                               Category__c = eachAc.Category__c,Placement_Layout__c = pConDet.Placement_Layout__c,
                                                                               Object_Name__c ='Placement Content Detail',recordTypeId = recordTypeId)); 
                                }
                                
                            }else if(context == 'Delete' && (pConDet.Page_Type__c != null && eachAc.Category__c == null || pConDet.Page_Type__c.ContainsIgnoreCase(eachAc.Category__c))){
                                  if(eachAc.Read_Only_Fields__c.contains('Placement Detail Deleted')){
                                lst_CreateOnchange.add(new History_Tracking__c(Field_Name__c = 'Placement Detail Deleted',  Brand__c = pConDet.Brand__c,
                                                                               Placement_Content__c = pConDet.Placement_Content__c,Placement_Content_Detail__c = pConDet.Id,
                                                                               Old_Value__c = URL+'<br/>'+Copy,Owner__c = eachAc.Team__c,Category__c = eachAc.Category__c,
                                                                               Placement_Layout__c = pConDet.Placement_Layout__c,Object_Name__c ='Placement Content Detail',
                                                                               recordTypeId = recordTypeId)); 
                                  }
                            }
                        }
                    }
                }
            }
        }
        // if record list is not empty insert the list
        if(!lst_CreateOnchange.isEmpty()) insert lst_CreateOnchange;
    }
    
    public static void setDefaultValues(){
        List<Placement_Content_Detail__c> contentDetailList = trigger.new;
        Set<Id> contentIds = new Set<Id>();
        
        for(Placement_Content_Detail__c cd : contentDetailList){
            if(String.isNotBlank(cd.Placement_Content__c)) contentIds.add(cd.Placement_Content__c);
        }
        
        if(contentIds.size() > 0){
            Set<String> contentIdWithCarouselSet = new Set<String>();

            for(Placement_Content__c content : [SELECT Id FROM Placement_Content__c 
                                               WHERE Id IN:contentIds AND Content_Type__c = 'Carousel' ]){
                contentIdWithCarouselSet.add(content.Id);
            }

            for(Placement_Content_Detail__c cd : contentDetailList){
                if(String.isNotBlank(cd.Placement_Content__c) && !contentIdWithCarouselSet.contains(cd.Placement_Content__c)){
                    cd.Slides__c = '';
                    cd.Sub_Type__c = '';
                }
            }
            
        }
    }
}