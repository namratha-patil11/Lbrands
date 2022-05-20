public class DGTL_PlacementContent_Handler implements TriggerFrmWrkTypes.ITriggerHandler{
    
    private static DGTL_PlacementContent_Handler placementContHandler;
    private TriggerFrmWrkTypes.TriggerParameters tp;
    
    public static boolean inProgress;
    
    private DGTL_PlacementContent_Handler (){ 
        
    }
    
    public static DGTL_PlacementContent_Handler getInstance(){
        
        if( placementContHandler == null )
            placementContHandler = new DGTL_PlacementContent_Handler();        
        
        return placementContHandler;
    }
    
    public void SetTriggerParam(TriggerFrmWrkTypes.TriggerParameters tp){
        this.tp = tp;
    }  
    
    public void beforeInsert(){ 
        DGTL_PlacementContentServices.defaultValuesOnBefore((List<Placement_Content__c>)Trigger.New, null);
    }
    
    public void beforeUpdate(){ 
        
       // DGTL_PlacementContentTrgHandler.checkForUpdatesBeforeDueDate((List<Placement_Content__c>) Trigger.New,(Map<Id,Placement_Content__c>) Trigger.OldMap);
        
        // Updates content name with combination of layout name - palacement type - main message
        DGTL_PlacementContentServices.defaultValuesOnBefore((List<Placement_Content__c>)Trigger.New, (Map<Id,Placement_Content__c>)Trigger.OldMap);
     //   DGTL_TasksOnfieldsChange.createTasksOnFieldsChange_PC((List<Placement_Content__c>) Trigger.New, (Map<Id,Placement_Content__c>)Trigger.OldMap);
    }
    
    public void afterInsert(){
         // Create Task on insert of Placement Content Record
       DGTL_PlacementContentTrgHandler.createInsertTask((List<Placement_Content__c>)Trigger.New);
       DGTL_PlacementContentTrgHandler.linkKods();
        
    }
    
    public void afterUpdate(){
        
        //DGTL_PlacementContentTrgHandler.checkForUpdates((List<Placement_Content__c>)Trigger.New, (Map<Id,Placement_Content__c>)Trigger.OldMap);
       
        // Create Placement Content History Record and Task on Change of any Field values Change in Placement Content Record
        DGTL_PlacementContentTrgHandler.createContentHistoryAndTasks((List<Placement_Content__c>)Trigger.New, (Map<Id,Placement_Content__c>)Trigger.OldMap);
        
         // Creation of History Tracking Records for History and Onchange RecordType on every field update
         DGTL_PlacementContentTrgHandler.createHistoryAndOnChange((List<Placement_Content__c>)Trigger.New, (Map<Id,Placement_Content__c>)Trigger.OldMap);
    }  
    
    public void beforeDelete(){
        
    }
    
    public void afterDelete(){
        
    }
    
    public void afterUndelete(){
        
    }
    
    public Static Boolean IsDisabled(){        
        return false;        
    }
    
    public Static void SetInProgress(boolean prog){        
        inProgress = prog;
    }
    
    public Static Boolean GetInProgress(){ 
        if(inProgress == null)
            inProgress = false;
        return inProgress;
    }     
    
}