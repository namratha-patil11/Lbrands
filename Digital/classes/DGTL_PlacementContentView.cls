public class DGTL_PlacementContentView {
    
    @AuraEnabled
    public static String getLayoutId(String RecordId){
        Placement_Content__c content = [SELECT ID,Name,Placement_Layout__c from Placement_Content__c
            						    WHERE id =:RecordId];
        String layoutRecordID = content.Placement_Layout__c;
        return layoutRecordID;
    }

}