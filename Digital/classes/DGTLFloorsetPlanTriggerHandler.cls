/* Name        : DGTLFloorsetPlanTriggerHandler
 * Description : This class is used in DGTL_Floorset_Plan.trigger and implements riggerFrmWrkTypes.ITriggerHandler
 * Author      : Vidya Sagar 
 */
public class DGTLFloorsetPlanTriggerHandler implements TriggerFrmWrkTypes.ITriggerHandler{
	
    private static DGTLFloorsetPlanTriggerHandler inst ;   
    private TriggerFrmWrkTypes.TriggerParameters tp;    
    public static boolean inProgress;    
    public static boolean isUpdateCall = true;
    public DGTLFloorsetPlanTriggerHandler(){
        
    }
    
    public static DGTLFloorsetPlanTriggerHandler getInstance(){
        if( inst == null )
            inst = new DGTLFloorsetPlanTriggerHandler();        
        return inst;
        
    }
    
    public void SetTriggerParam(TriggerFrmWrkTypes.TriggerParameters tp){
        this.tp = tp;
    }
    
    // This method is used to set default values before insert
    public void BeforeInsert(){ 
        DGTLFloorsetPlanServices.defaultFieldValues(Trigger.new);
    }
    // This method is used to set default values before insert
    public void BeforeUpdate(){ 
        DGTLFloorsetPlanServices.defaultFieldValues(Trigger.new);
    }
    
    public void BeforeDelete(){        
    }
    
    public void AfterInsert(){     
    }
    
    public void AfterUpdate(){     
    }
    public void AfterDelete(){     
    }
    public void AfterUndelete(){     
    }
    
     public Static Boolean IsDisabled(){
        
        return false;        
    }
    
    public Static void SetInProgress(boolean porg){
        
        inProgress = porg;
    }
    
    public Static Boolean GetInProgress(){
        if(inProgress == null)
            inProgress = false;
        return inProgress;
    } 
}