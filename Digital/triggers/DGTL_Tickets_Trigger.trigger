trigger DGTL_Tickets_Trigger on DGTL_Tickets__c  (before insert, before update) {
    TriggerDispatcher.run( new TriggerFrmWrkTypes.TriggerParameters(Trigger.isBefore, Trigger.isAfter, Trigger.isDelete, Trigger.isUnDelete,
                                                                    Trigger.isInsert, Trigger.isUpdate, Trigger.isExecuting, 
                                                                    Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap ), 
                          DGTL_TicketsTriggerHandler.getInstance());
}