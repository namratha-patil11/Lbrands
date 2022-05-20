/* Name        : DGTL_DeleteLiveUsersScheduledBatch
 * Description : This class is used to schedule to delete old live users data
 * Author      : Vidya Sagar 
 */
public class DGTL_DeleteLiveUsersScheduledBatch implements Schedulable, Database.Stateful {
    
    /*    
    public Database.querylocator start(Database.BatchableContext BC){ 
            DateTime lastPollDeldatetime = system.now().addMinutes(-30);
            return Database.getQueryLocator('SELECT Id,Last_Poll_Time__c FROM Digital_Live_Users__c WHERE Last_Poll_Time__c<=:lastPollDeldatetime');
        
    }
    
    public void execute(Database.BatchableContext BC, List<Digital_Live_Users__c> scope){        
		delete scope;        
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    */
    
    //schedule 
    public void execute(SchedulableContext SC) {        
       //Database.executeBatch(new DGTL_DeleteLiveUsersScheduledBatch());   
       DateTime lastPollDeldatetime = system.now().addMinutes(-30);
       delete [SELECT Id,Last_Poll_Time__c FROM Digital_Live_Users__c WHERE Last_Poll_Time__c<=:lastPollDeldatetime];
    }
   
}