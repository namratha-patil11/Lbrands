public class DGTL_AccessManagement_Handler implements TriggerFrmWrkTypes.ITriggerHandler{
    private static DGTL_AccessManagement_Handler accessManagementHandler;
    private TriggerFrmWrkTypes.TriggerParameters tp;
    
    public static boolean inProgress;
    
    private DGTL_AccessManagement_Handler (){ 
        
    }
    
    public static DGTL_AccessManagement_Handler getInstance(){
        
        if( accessManagementHandler == null )
            accessManagementHandler = new DGTL_AccessManagement_Handler();        
        
        return accessManagementHandler;
    }
    
    public void SetTriggerParam(TriggerFrmWrkTypes.TriggerParameters tp){
        this.tp = tp;
    }  
    
    public void beforeInsert(){ 
    }
    
    public void beforeUpdate(){ 
         // clear last run time field if schedule time is modified
        DGTL_AccessManagement_Services.clearLastRunTime((List<DGTL_Access_Management__c>)Trigger.New, (Map<Id,DGTL_Access_Management__c>)Trigger.OldMap);
    }
    
    public void afterInsert(){
        
    }
    
    public void afterUpdate(){
      
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