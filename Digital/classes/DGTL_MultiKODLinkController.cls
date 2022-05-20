public class DGTL_MultiKODLinkController {
    
    @AuraEnabled
    public static String fetchKODDetails(String kodId){
        String kodName= '';
        try{
           KOD__c kod = [SELECT Name,Offer_Status__c FROM KOD__c WHERE Id = :kodId];
            if(kod.Offer_Status__c.equalsIgnoreCase('APPROVED')){
                kodName = kod.Name;
            }else{
                throw new AuraException('KOD has not been approved');
            }
        }catch(Exception e){
            throw new AuraException(e.getMessage());
        }
        return kodName;
    }
    
    @AuraEnabled
    public static List<Map<String,String>> fetchPlacementKODs(String contentId){
        List<Map<String,String>> placementKodMapList = new List<Map<String,String>>();
        
        for(Placement_KOD__c pKod : [SELECT KOD__r.Name,KOD__c FROM Placement_KOD__c 
                                     WHERE Placement_Content__c = :contentId 
                                     AND KOD__c != null])
        {
            Map<String,String> placementKodMap = new Map<String,String>();
            placementKodMap.put('name',pKod.KOD__r.Name);
            placementKodMap.put('id',pKod.KOD__c);
            placementKodMapList.add(placementKodMap);
        }
        return placementKodMapList;
    }
    
     @AuraEnabled
    public static void linkPlacementKODs(String contentId, List<String> kodIds, List<String> removedKODs){
        System.debug('removedKODs-----'+removedKODs);
        System.debug('kodIds-----'+kodIds);
        List<Placement_KOD__c> pKodList = new List<Placement_KOD__c>();
        Set<Id> liveKodIdSet = new Set<Id>();
        
        if(kodIds.size() > 0){
            for(Placement_KOD__c pKOD : [SELECT KOD__c FROM Placement_KOD__c 
                                         WHERE Placement_Content__c = :contentId 
                                         AND KOD__c IN :kodIds])
            {
                liveKodIdSet.add(pKOD.KOD__c);
            }
            
            for(String kodId : kodIds){
                if(!liveKodIdSet.contains(kodId)) pKodList.add(new Placement_KOD__c(Placement_Content__c = contentId, KOD__c = kodId));
            }
        }        
        
        
        try{
            if(pKodList.size() > 0) insert pKodList;
            if(removedKODs != null && removedKODs.size() > 0) DELETE[SELECT Id FROM Placement_KOD__c 
                                                                     WHERE Placement_Content__c = :contentId 
                                                                     AND KOD__c IN :removedKODs];
        }catch(DMLException de){
            throw new AuraException(de.getMessage());
        }
        
        
    }

}