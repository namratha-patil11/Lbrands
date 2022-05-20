trigger DGTL_PlacementContentDetail_Trigger on Placement_Content_Detail__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	
	TriggerDispatcher.run( new TriggerFrmWrkTypes.TriggerParameters(Trigger.isBefore, Trigger.isAfter, Trigger.isDelete, Trigger.isUnDelete,
                                                                    Trigger.isInsert, Trigger.isUpdate, Trigger.isExecuting, 
                                                                    Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap),
        
        
        DGTL_PlacementContentDetail_Handler.getInstance());
}