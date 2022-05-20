trigger DGTL_PlacementLayoutTrigger on Placement_Layout__c (before Insert, before Update,after Update, after insert, after Delete) 
{
    if(Trigger.IsBefore)
    {
        if(Trigger.IsInsert)
        {
            DGTL_PlacementLayoutTriggerHandler.updateplacementLayoutExtId(Trigger.New,Null);
           
        }
        if(Trigger.IsUpdate)
        {
            DGTL_PlacementLayoutTriggerHandler.updateplacementLayoutExtId(Trigger.New,Trigger.OldMap);
          
        }
    }
    if(Trigger.IsAfter){
        
        if(Trigger.IsInsert){
            
            DGTL_PlacementLayoutTriggerHandler.updateFloorsetCalendar(Trigger.New, Trigger.OldMap, false);
        }
        if(Trigger.IsUpdate)
        {
            DGTL_PlacementLayoutTriggerHandler.updateFloorsetCalendar(Trigger.New, Trigger.OldMap, false);    
            
        }
        if(Trigger.Isdelete)
        {
            system.debug('Afterdelete');
            DGTL_PlacementLayoutTriggerHandler.updateFloorsetCalendar(Trigger.New, Trigger.OldMap, true); 
        } 
    }
    
}