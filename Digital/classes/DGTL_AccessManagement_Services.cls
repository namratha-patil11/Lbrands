public class DGTL_AccessManagement_Services {
    
    public static void clearLastRunTime (List<DGTL_Access_Management__c> list_AccessMgmtNew, Map<Id,DGTL_Access_Management__c> map_AccessMgmtOld){
        Id recordTypeId = Schema.SObjectType.DGTL_Access_Management__c.getRecordTypeInfosByName().get('Notification').getRecordTypeId();
        list<DGTL_Access_Management__c> list_AccessMgmtToUpdate = new list<DGTL_Access_Management__c>();
        
        for(DGTL_Access_Management__c accessMgmt : list_AccessMgmtNew)
        {   
            if(accessMgmt.RecordTypeId == recordTypeId && 
               accessMgmt.Schedule_Interval_Time__c != map_AccessMgmtOld.get(accessMgmt.Id).get('Schedule_Interval_Time__c')){
                   accessMgmt.Last_Schedule_time__c = null;
            }
        }
    }
}