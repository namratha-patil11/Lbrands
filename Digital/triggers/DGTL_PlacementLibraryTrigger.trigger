trigger DGTL_PlacementLibraryTrigger on Placement_Library__c (Before Insert,Before Update,After Insert) 
{
    if(Trigger.IsBefore)
    {
        if(Trigger.IsInsert)
        {
            DGTL_PlacementLibraryTriggerHandler.updateDefaults(Trigger.New,Null);
        }
        if(Trigger.IsUpdate)
        {
            DGTL_PlacementLibraryTriggerHandler.updateDefaults(Trigger.New,Trigger.OldMap);
        }
    }
    if(Trigger.IsAfter)
    {
        if(Trigger.IsInsert)
        {
            DGTL_PlacementLibraryTriggerHandler.cloneContentDetails(Trigger.New);
        }
        
        
    }
}