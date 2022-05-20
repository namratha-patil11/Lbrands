public class DGTL_WebRemoter {
    
    @AuraEnabled
    public static List<Placement_Content__c> getFutureContents(String contentId){
       List<Placement_Content__c> plcList = new List<Placement_Content__c>();
      
        Placement_Content__c pc = [SELECT Type__c,Id,Placement_Layout__r.Date_Formula__c,Placement_Layout__r.Time_No__c,Placement_Library__c 
                                   FROM Placement_Content__c 
                                   WHERE Id=:contentId];
        Date layoutDate = pc.Placement_Layout__r.Date_Formula__c;
        Decimal layoutTime = pc.Placement_Layout__r.Time_No__c;
        try{
            for(Placement_Content__c futureContent : [SELECT Id,Name,Main_Message__c, Placement_Layout__r.Name,CreatedDate,Placement_Library__c,Compared_Placement_Layout__c,
                                                      Placement_Layout__r.Date_Formula__c,Placement_Layout__r.Time_No__c From Placement_Content__c
                                                      WHERE Type__c =: pc.Type__c AND Active__c = TRUE AND Placement_Library__c=:pc.Placement_Library__c 
                                                      AND Placement_Layout__r.Type__c='Layout'
                                                      AND (Placement_Layout__r.Date_Formula__c >=:layoutDate 
                                                          OR (Placement_Layout__r.Date_Formula__c =:layoutDate 
                                                              AND Placement_Layout__r.Time_No__c >:layoutTime))
                                                      ORDER BY Placement_Layout__r.Date_Formula__c,Placement_Layout__r.Time_No__c])
            {
                plcList.add(futureContent);
            } 
            System.debug('plcList==='+plcList.size());
        }catch(QueryException qe){
            throw new AuraException('No records found.');
        }catch(Exception e){
            throw new AuraException(e.getMessage());
        }
        
        
        return plcList;
    }

}
