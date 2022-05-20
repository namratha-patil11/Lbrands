trigger DGTL_PlacementContent_Trigger on Placement_Content__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
     TriggerDispatcher.run( new TriggerFrmWrkTypes.TriggerParameters(Trigger.isBefore, Trigger.isAfter, Trigger.isDelete, Trigger.isUnDelete,
                                                                    Trigger.isInsert, Trigger.isUpdate, Trigger.isExecuting, 
                                                                    Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap),
        
        
        DGTL_PlacementContent_Handler.getInstance());
}