trigger DGTL_Floorset_Plan on DGTL_Floorset_Plan__c (before insert, before update) {
    TriggerDispatcher.run( new TriggerFrmWrkTypes.TriggerParameters(Trigger.isBefore, Trigger.isAfter, Trigger.isDelete, Trigger.isUnDelete,
                                                                    Trigger.isInsert, Trigger.isUpdate, Trigger.isExecuting, 
                                                                    Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap ), 
                          DGTLFloorsetPlanTriggerHandler.getInstance());
}