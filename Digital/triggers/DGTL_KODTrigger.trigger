trigger DGTL_KODTrigger on KOD__c (after update) {
    
    if(Trigger.isAfter && Trigger.isUpdate){
        new DGTL_KODTriggerHandler().handleKODStatusChange();
    }

}