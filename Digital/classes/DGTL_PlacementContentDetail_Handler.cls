public class DGTL_PlacementContentDetail_Handler implements TriggerFrmWrkTypes.ITriggerHandler{
    private static DGTL_PlacementContentDetail_Handler placementContHandler;
    private TriggerFrmWrkTypes.TriggerParameters tp;
    
    public static boolean inProgress;
    
    private DGTL_PlacementContentDetail_Handler (){ 
    }
    
    public static DGTL_PlacementContentDetail_Handler getInstance(){
        
        if( placementContHandler == null )
            placementContHandler = new DGTL_PlacementContentDetail_Handler();        
        
        return placementContHandler;
    }
    
    public void SetTriggerParam(TriggerFrmWrkTypes.TriggerParameters tp){
        this.tp = tp;
    }  
    
    public void beforeInsert(){
        DGTL_PlacementContentDetTrgServices.setDefaultValues();
    }
    
    public void beforeUpdate(){
        DGTL_PlacementContentDetTrgServices.setDefaultValues();
    }
    
    
    
    public void afterInsert(){
        // Create Placement Task on create of Placement Content Detail Record
        DGTL_PlacementContentDetTrgServices.createInsertTask((Map<Id,Placement_Content_Detail__c>)Trigger.NewMap);
    }
    
    public void afterUpdate(){
        // Create Placement Content Detail History Record on Change of any Field values Change in Placement Content Detail Record
        DGTL_PlacementContentDetTrgServices.createContentHistory((List<Placement_Content_Detail__c>)Trigger.New, (Map<Id,Placement_Content_Detail__c>)Trigger.OldMap);
        
        // Creation of History Tracking Records for History and Onchange RecordType on every field update
        DGTL_PlacementContentDetTrgServices.createHistoryAndOnChange((List<Placement_Content_Detail__c>)Trigger.New, (Map<Id,Placement_Content_Detail__c>)Trigger.OldMap);
    }  
    
    public void beforeDelete(){
        // Create Placement Task on delete of Placement Content Detail Record
        DGTL_PlacementContentDetTrgServices.createDeleteHistoryTask((Map<Id,Placement_Content_Detail__c>)Trigger.OldMap);
    }
    
    public void afterDelete(){
        // Create Placement Task on delete of Placement Content Detail Record
       //DGTL_PlacementContentDetTrgServices.createDeleteTask((Map<Id,Placement_Content_Detail__c>)Trigger.OldMap);
        
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