trigger DGTL_TaskTrigger on DGTL_Task__c (after update) {
	
    if(Trigger.isAfter && Trigger.isUpdate){
        DGTL_TaskTriggerHandler handler = new DGTL_TaskTriggerHandler();
        handler.manageTask();
    }    
 
}