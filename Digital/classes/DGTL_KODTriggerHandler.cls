public class DGTL_KODTriggerHandler {
    
    public void handleKODStatusChange(){
        List<KOD__c> kodList = (List<KOD__c>) trigger.new;
        Map<Id,KOD__c> kodOldMap = (Map<Id,KOD__c>) trigger.oldMap;
        Set<Id> cancelledKODIdSet = new Set<Id>();
        
        for(KOD__c kod : kodList){
            if(kod.Offer_Status__c != kodOldMap.get(kod.Id).Offer_Status__c){
                
                if(kod.Offer_Status__c.equalsIgnoreCase('Cancelled')){
                    cancelledKODIdSet.add(kod.Id);
                }
            }
        }
        
        // START - single kod placement content object logic
       /* if(cancelledKODIdSet.size() > 0){
            Set<Id> contentIds = new Set<Id>();
            List<DGTL_Task__c> taskToUpdate = new List<DGTL_Task__c>();
            List<Placement_Content__c> pcToUpdate = new List<Placement_Content__c>();
            
            for(Placement_Content__c pc : [SELECT Id,Active__c FROM Placement_Content__c WHERE KOD__C IN:cancelledKODIdSet]){
                pc.Active__c = false;
                pcToUpdate.add(pc);
                contentIds.add(pc.Id);
            }
            
            if(pcToUpdate.size() > 0){
                update pcToUpdate;
            }
            
            for(DGTL_Task__c task : [SELECT Id, Status__c FROM DGTL_Task__c WHERE RecordType.DeveloperName='User_Task' AND 
                                     (Placement_Content__c IN :contentIds 
                                      OR Parent_Task__r.Placement_Content__c IN:contentIds)])
            {
                task.Status__c = 'Cancelled';
                taskToUpdate.add(task);
            }
            
            if(taskToUpdate.size() > 0){
                update taskToUpdate;
            }
        } */// END - single kod placement content object logic
        
        
        // junction object logic 
        if(cancelledKODIdSet.size() > 0){
            Set<Id> contentIds = new Set<Id>();
            
            for(Placement_KOD__c pKod : [SELECT Id,KOD__c,Placement_Content__c FROM Placement_KOD__c
                                         WHERE KOD__c IN:cancelledKODIdSet AND Placement_Content__r.Date_Formula__c > TODAY]){
                contentIds.add(pKod.Placement_Content__c);
            }
            
            // logic with content
            if(contentIds.size() > 0){
                List<Placement_Content__c> pcToUpdate = new List<Placement_Content__c>();
                List<DGTL_Task__c> taskToUpdate = new List<DGTL_Task__c>();
                
                for(Placement_Content__c pc : [SELECT Id,Active__c FROM Placement_Content__c WHERE Id IN:contentIds]){
                    pc.Active__c = false;
                    pcToUpdate.add(pc);
                }
                
                if(pcToUpdate.size() > 0){
                    update pcToUpdate;
                }
                
                for(DGTL_Task__c task : [SELECT Id, Status__c FROM DGTL_Task__c WHERE RecordType.DeveloperName='User_Task' AND 
                                         (Placement_Content__c IN :contentIds 
                                         OR Parent_Task__r.Placement_Content__c IN:contentIds)]){
                    task.Status__c = 'Cancelled';
                    taskToUpdate.add(task);
                }
                
                if(taskToUpdate.size() > 0){
                    update taskToUpdate;
                }
                
                // not putting try catch for now...
                DELETE[SELECT Id FROM Placement_KOD__c WHERE Placement_Content__c IN:contentIds];
            }
            
        } 
    }

}