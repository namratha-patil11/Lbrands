/* Name : DGTL_TicketsTriggerHandler
 * Description : This class is used in DGTL_Tickets_Trigger.trigger
 * Author : Vidya Sagar
 * Date     : 23 March 2020 
 */
public class DGTL_TicketsTriggerHandler implements TriggerFrmWrkTypes.ITriggerHandler{
    
    private static DGTL_TicketsTriggerHandler inst ;   
    private TriggerFrmWrkTypes.TriggerParameters tp;    
    public static boolean inProgress;    
    public static boolean isUpdateCall = true;
    public DGTL_TicketsTriggerHandler(){
        
    }
    
    public static DGTL_TicketsTriggerHandler getInstance(){
        if( inst == null )
            inst = new DGTL_TicketsTriggerHandler();        
        return inst;
        
    }
    
    public void SetTriggerParam(TriggerFrmWrkTypes.TriggerParameters tp){
        this.tp = tp;
    }
    
    public void BeforeInsert(){ 
        DGTL_TicketsServices.defaultFieldValues(Trigger.new);
    }
    
    public void BeforeUpdate(){ 
        DGTL_TicketsServices.defaultFieldValues(Trigger.new);
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