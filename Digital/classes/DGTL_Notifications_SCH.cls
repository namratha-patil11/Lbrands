global class DGTL_Notifications_SCH implements Schedulable{
    
    global void execute (SchedulableContext ctx) {
   //public void executeSchedule(){
        List<DGTL_Access_Management__c> list_AccessMgmtToSchedule = New List<DGTL_Access_Management__c>();
        Map<String, List<Id>> map_PublicGroupMembers = new Map<String , List<Id>>(); // to address - public group members based on Chatter group Name
        Map<String, List<History_Tracking__c>> map_LayoutHistoryRecords = new Map<String , List<History_Tracking__c>>(); // history records for each Layout
        Map<String, String> map_GroupNames = new Map<String , String>(); //  Chatter group Name
        Set<String> groupNames = new Set<String>();
        List<History_Tracking__c> lst_TaskWithoutContent = new List<History_Tracking__c> (); // List of History_Tracking__c without Content Value - used to delete

        
        // map<b-o-cat, map<layout, list<rec>>>
        Map<String, Map<String, List<History_Tracking__c>>> map_accessRecords = new Map<String , Map<String, List<History_Tracking__c>>>(); 
        // map<layout, list<rec>
        Map<String, List<History_Tracking__c>> map_LayoutList = new Map<String, List<History_Tracking__c>>();
        
        // get access management records for notification
        list_AccessMgmtToSchedule = getAccessMgmtList();
        
        // build dynamic query to get related tasks
        Id recordTypeId = Schema.SObjectType.History_Tracking__c.getRecordTypeInfosByName().get('OnChange').getRecordTypeId();
        
        String query = 'SELECT id,Name,Brand__c,Category__c,Field_Name__c,Field_API__c,Object_Name__c,New_Value__c,Old_Value__c,Owner__c,Placement_Content__r.Name,Placement_Layout__c,Placement_Layout__r.Name,';
        query += 'Placement_Content__c,Placement_Content__r.Placement_Layout__c,Placement_Content__r.Main_Message__c,CreatedBy.Name,CreatedDate,LastModifiedBy.Name,LastModifiedDate,Placement_Content_Detail__c,  ';
      	query += 'Floorset_Plan__c,Floorset_Plan_ID__c ';
        query += 'From History_Tracking__c where Owner__c != null AND recordTypeId =:recordTypeId ';
        
        // if accemanagemt is not empty ass condition to get Task records
        if(!list_AccessMgmtToSchedule.isEmpty()){
            query += ' AND (';
            for(DGTL_Access_Management__c accMgmt : list_AccessMgmtToSchedule){
                // query +='(brand__c =\'' + accMgmt.Brands__c  + '\' AND Owner__c = \'' + accMgmt.Team__c +'\' AND  Category__c = \''+ accMgmt.Category__c + '\' ) OR ';
                String category = String.isNotBlank(accMgmt.Category__c) ?  '\''+ accMgmt.Category__c + '\'' : null ; 
                query +='(brand__c =\'' + accMgmt.Brands__c  + '\' AND Owner__c = \'' + accMgmt.Team__c +'\' AND  Category__c ='+category+' ) OR ';
                map_GroupNames.put(accMgmt.brands__c+'-'+accMgmt.Team__c+'-'+accMgmt.Category__c,accMgmt.Chatter_Subscribed_Group__c); // group names for Brand - team - Category
                groupNames.add(accMgmt.Chatter_Subscribed_Group__c); // set of Group Names
            }
            query = query.removeEnd('OR ');
            query += ' )';
        }
        query += ' Order BY Floorset_Plan__c,brand__c,Owner__c,Category__c,Placement_Layout__c,Placement_Content__c,Object_Name__c';        // get the History_Tracking for access management Records to be scheduled.
        List<History_Tracking__c> lst_Task = Database.query(query); 
        
        // Update the schedule time for access management Records.
       if(!list_AccessMgmtToSchedule.isEmpty()) updateScheduleTime(list_AccessMgmtToSchedule);
        
        if(lst_Task.size() == 0) return;
        
        for(History_Tracking__c eachRec : lst_Task ) {
            // add tasks to a list if Placement Content value is null
            if(eachRec.Placement_Content__c == null){
                lst_TaskWithoutContent.add(eachRec);
            }
            else{
                if(map_accessRecords.get(eachRec.brand__c+'-'+eachRec.Owner__c+'-'+eachRec.Category__c) == null){
                    map_accessRecords.put(eachRec.brand__c+'-'+eachRec.Owner__c+'-'+eachRec.Category__c,new map<String,list<History_Tracking__c>>{eachRec.Placement_Layout__c+'~'+eachRec.Placement_Layout__r.Name => new list<History_Tracking__c>{eachRec}});
                } 
                else {
                    if(map_accessRecords.get(eachRec.brand__c +'-'+eachRec.Owner__c+'-'+eachRec.Category__c).get(eachRec.Placement_Layout__c+'~'+eachRec.Placement_Layout__r.Name) == null){
                        map_accessRecords.get(eachRec.brand__c+'-'+ eachRec.Owner__c+'-'+eachRec.Category__c).put(eachRec.Placement_Layout__c+'~'+eachRec.Placement_Layout__r.Name, new list<History_Tracking__c>());                
                    }
                    map_accessRecords.get(eachRec.brand__c+'-'+eachRec.Owner__c+'-'+eachRec.Category__c).get(eachRec.Placement_Layout__c+'~'+eachRec.Placement_Layout__r.Name).add(eachRec);
                }
            }
        }
        
        if(lst_TaskWithoutContent.size() > 0) delete lst_TaskWithoutContent; //Delete tasks list if Placement Content value is null
        
        system.debug(groupNames);  
        if(groupNames.size() > 0){  // get members based on Groups
            map_PublicGroupMembers = getGroupMemberIds(groupNames);
            if(map_PublicGroupMembers.size() > 0){
                System.debug('map_accessRecords============='+map_accessRecords);
                sendTaskNotification(map_PublicGroupMembers, map_GroupNames, map_accessRecords);
            }        
        }
    }
    
    public List<DGTL_Access_Management__c> getAccessMgmtList(){
        
        Id taskRecId =  Schema.SObjectType.DGTL_Access_Management__c.getRecordTypeInfosByName().get('Notification').getRecordTypeId();
        List<string> List_Brands = DGTL_DataAccessor.getPicklistValues('Placement_Layout__c', 'Brands__c');
        List<DGTL_Access_Management__c> list_AccessMgmtToSchedule = new List<DGTL_Access_Management__c>();
        Datetime timeNow = Datetime.now();
        
        List<DGTL_Access_Management__c> list_AccessMgmt = [SELECT Name, Team__c,Schedule_Interval_Time__c,Chatter_Subscribed_Group__c,
                                                           			Read_Only_Fields__c,Last_Schedule_time__c,Category__c,Brands__c
                                                           FROM DGTL_Access_Management__c  
                                                           WHERE Team__c != null AND Brands__c IN : List_Brands AND RecordTypeId =: taskRecId and Object_Name__c = 'Placement_Content__c'];        
        for(DGTL_Access_Management__c accessMgmt : list_AccessMgmt){
            String timeInterval = accessMgmt.Schedule_Interval_Time__c;
            DateTime lastScheduleTime = accessMgmt.Last_Schedule_time__c;
            Datetime nextRunTime;
            Integer int_timeInterval;
            
            if(timeInterval.contains('mins')){
                int_timeInterval = Integer.valueOf(timeInterval.substringBefore(' mins'));
                if(lastScheduleTime != null) {
                    nextRunTime = lastScheduleTime.addMinutes(int_timeInterval);
                }else{
                    nextRunTime = Datetime.now();
                }
            }else if(timeInterval.contains('hrs')){
                int_timeInterval = Integer.valueOf(timeInterval.substringBefore(' hrs'));
                if(lastScheduleTime != null) {
                    nextRunTime = lastScheduleTime.addHours(int_timeInterval);
                }else{
                    nextRunTime = Datetime.now();
                }
            }else{ // if Schedule_Interval_Time__c field is empty
                nextRunTime = Datetime.now();
            }
            if(nextRunTime >= Datetime.now().addMinutes(-4) && nextRunTime <= Datetime.now().addMinutes(4)){
                list_AccessMgmtToSchedule.add(accessMgmt);
            }
        }
        return list_AccessMgmtToSchedule;
    }
    
    //Update Last Schedule time of Access management records
    public void updateScheduleTime(list<DGTL_Access_Management__c> list_AccessMgmt){
        List<DGTL_Access_Management__c> list_AccessMgmtToUpdate = New List<DGTL_Access_Management__c>();        
        for(DGTL_Access_Management__c accessRec : list_AccessMgmt){
            accessRec.Last_Schedule_time__c = Datetime.now();
            list_AccessMgmtToUpdate.add(accessRec);
        }        
        if(!list_AccessMgmtToUpdate.isEmpty()) update list_AccessMgmtToUpdate;
    }
    
    public  Map<String, list<id>> getGroupMemberIds(Set<String> groupNameSet){
        Map<String, list<id>> groupMemberIdSet = new Map<String, list<id>>();
        for(CollaborationGroupMember groupMember : [SELECT MemberId ,CollaborationGroup.Name FROM CollaborationGroupMember 
                                                    WHERE CollaborationGroup.Name IN :groupNameSet])
        {	
            String groupName = String.valueOf(groupMember.CollaborationGroup.Name);
            if(groupMemberIdSet.get(groupName) == null){
                groupMemberIdSet.put(groupName,new list<Id>());
            }
            groupMemberIdSet.get(groupName).add(groupMember.MemberId);
        }
        return groupMemberIdSet;
    }
    
    public string buildMailBody(History_Tracking__c history, boolean addMainMessage) {
        string emailBody = '';
        //emailBody += '<tr>';
        emailBody += (addMainMessage && history.Placement_Content__r.Main_Message__c != null)? '<td> '+history.Placement_Content__r.Main_Message__c+' </td>' : '<td/>';
        emailBody += '<td ';
        emailBody += (String.isNotBlank(history.Object_Name__c) && history.Object_Name__c.containsIgnoreCase('Detail'))  ?  ' style="font-size:11px"> ' : '> ';
        emailBody += history.Field_Name__c+'</td>';
        if(String.isNotBlank(history.Field_Name__c) && (history.Field_Name__c.containsIgnoreCase('Deleted') || 
              history.Field_Name__c.containsIgnoreCase('Added') || history.Field_Name__c.containsIgnoreCase('Activated'))){
            emailBody += '<td colspan="2"> '+history.Old_Value__c + ' </td>';
        }/*else if(history.Field_Name__c == 'Content Added'){
            emailBody += '<td colspan="2"> </td>';
        }*/else{
            emailBody += ' <td> ';
            emailBody += String.isBlank(history.Old_Value__c)  ? ' </td>' : history.Old_Value__c +' </td>';
            emailBody += '<td> ';
            emailBody += String.isBlank(history.New_Value__c)  ?  ' </td>' : history.New_Value__c +' </td>';
        }
        emailBody += '<td> ';  emailBody +=history.createdBy.Name == null ? history.LastModifiedBy.Name+' </td>' : history.createdBy.Name+' </td>';
        emailBody += '<td> '+history.CreatedDate+' </td>' ;
        emailBody += '</tr>';
        return emailBody;
    }
    
    public void sendTaskNotification(map<String, List<Id>> members, 
                                     Map<String, String> map_GroupNames,
                                     Map<String,Map<String,List<History_Tracking__c>>> map_accessRecords) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        List<DGTL_Task__c> list_NewTasks = new List<DGTL_Task__c>();
        Map<String, List<DGTL_Task__c>> map_NewTasks = new Map<String, List<DGTL_Task__c>>();
        
        List<History_Tracking__c> list_deleteTasks = new List<History_Tracking__c>();
        String emailStingByTeam = '';
        Id TaskRecordTypeId = Schema.SObjectType.DGTL_Task__c.getRecordTypeInfosByName().get('Notification').getRecordTypeId();
        String detailBody ;
        Id id_Placement ;
        //String currentFloorSetId = '';
        String prevFloorSetId = '';
                                         
        //system.debug('I am in!!');
        //----------------new Task creation Block---------------------------Start-------------------
        //
        string str_MainTableHeader = '<table border="1" style="border-collapse: collapse"><tr><th> Layout Name </th><th> Content  </th><th> Field </th><th> Old Value </th><th> New Value </th><th> Modified By</th> <th>Modified Date</th></tr>';
        string str_InnerTableHeader = '<table border="1" style="border-collapse: collapse"><tr><th> Main Message  </th><th> Field </th><th> Old Value </th><th> New Value </th><th> Modified By</th> <th>Modified Date</th></tr>';
                          
        for(String accessRecordsString : map_accessRecords.keyset()){
            String emailBody = '';            
            for(String eachLayout : map_accessRecords.get(accessRecordsString).keyset()) {
                String str_ContentPlacement = str_InnerTableHeader;
                String str_ContentDetail = str_InnerTableHeader;
                id id_PlacementContent;
                boolean detailHasMessage = false;        
                
                boolean boo_LayoutLink = false;
                for( History_Tracking__c history : map_accessRecords.get(accessRecordsString).get(eachLayout)){
                    String temp ='';                 
                    if(prevFloorSetId != history.Floorset_Plan_ID__c ){ 
                        if(prevFloorSetId != '')  emailBody +='</table><br/>';//skip first time                        
                        emailBody +='<div stlye="text-align:center;"><H3>'+history.Floorset_Plan__c+' </H3></div>' ;                      
                        emailBody += str_MainTableHeader;                      
                        prevFloorSetId = history.Floorset_Plan_ID__c;
                    }
                    if(!boo_LayoutLink) {
                        boo_LayoutLink = true; 
                        emailBody += '<tr><td rowspan='+ map_accessRecords.get(accessRecordsString).get(eachLayout).size()+'> <a href="https://'+URL.getSalesforceBaseUrl().getHost()+'/lightning/n/Layouts?c__layout=%5Bobject%20Object%5D&c__ispageReference=true&c__Brands=&c__layoutId='+ eachLayout.split('~')[0]+'&c__DeviceType=">'+eachLayout.split('~')[1] +'</a></td>';
                    }  
                    id_PlacementContent = history.Placement_Content__c;
                    temp = buildMailBody(history, true);
                    emailBody += temp;
                    
                    if(history.Object_Name__c == 'Placement Content')  str_ContentPlacement += temp;
                    else str_ContentDetail += temp;
                    
                    list_deleteTasks.add(history);
                } 
                DGTL_Task__c task =  New DGTL_Task__c(Changed_Content_Fields__c ='<b>Placement Content </b>'+ str_ContentPlacement +'</table>' ,
                                                      Content_Detail_Information__c ='<b>Placement Content Detail </b>'+ str_ContentDetail +'</table>' ,
                                                      RecordTypeId = TaskRecordTypeId,
                                                      DGTL_TaskOwner__c = accessRecordsString.split('-')[1],
                                                      Placement_Content__c= id_PlacementContent);
                if(String.isNotBlank(accessRecordsString.split('-')[2]) && accessRecordsString.split('-')[2] != 'null'){
                    task.Category__c =  accessRecordsString.split('-')[2];
                } //Task creation 
                list_NewTasks.add(task);
            }
            emailBody += '</table>'; //System.debug('accessRecordsString----'+accessRecordsString);
            String groupNameString = map_GroupNames.get(accessRecordsString); //System.debug('groupNameString----'+groupNameString);
            if(members.get(groupNameString) != null){
                for(Id mem : members.get(groupNameString)) {		
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTargetObjectId(mem);
                    mail.setSubject('Latest Placement Layout Updates ');system.debug('emailBody-----'+emailBody);
                    mail.setHtmlBody('Below are the recent layout updates.<br/>' + emailBody + '<br/><br/>');
                    mail.setSaveAsActivity(false);
                    mail.setccAddresses(new list<string>{});
                    emails.add(mail);
                }
            } 
        }     
        //system.debug('-emails-- '+emails.size());
      
        if(emails.size() > 0 ) Messaging.sendEmail(emails);
        if(list_NewTasks.size() > 0)  insert list_NewTasks;  // system.debug('list_NewTasks---'+list_NewTasks);     
        if(list_deleteTasks.size() > 0) delete list_deleteTasks;        
    }
    
}