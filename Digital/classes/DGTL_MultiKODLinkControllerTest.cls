@isTest
public class DGTL_MultiKODLinkControllerTest {
    
    @testSetup
    static void setupData(){
        List<KOD__c> kodList = new List<KOD__c>();
        kodList.add(new KOD__c(Offer_Status__c='Approved',Name='Test1'));
        kodList.add(new KOD__c(Offer_Status__c='Cancelled',Name='Test2'));
        
        insert kodList;
        
        DGTL_Floorset_Plan__c vsFloorsetPlan = DGTL_TestDataFactory.createFloorsetPlan('VS',DATE.today().addDays(-1),'2 AM','Update');
        insert vsFloorsetPlan;
        
        Placement_Layout__c layout = DGTL_TestDataFactory.createPlacementLayout('VS','Home Page','Desktop',vsFloorsetPlan.Id, 'Layout');
        insert layout;
        
        Placement_Library__c plibrary = DGTL_TestDataFactory.createPlacementLibrary(DATE.today().addDays(-1), DATE.today().addDays(1), 'VS', 'Home Page', '1 AM', '6 AM', 'Desktop', 'Approved', 'Offer', 'Main Message - Desktop');
        insert plibrary;
        
        List<Placement_Content__c> pContList = DGTL_TestDataFactory.createPlacementContentlist(null,'', 1,
                                                                                               null,'','Video',
                                                                                               'Controlled','Feature','Offer');
        pContList[0].S_No__c = 1;
        pContList[0].Placement_Library__c = plibrary.Id;
        pContList[0].Main_Message__c = 'Main Message 1 - Desktop';
        pContList[0].Placement_Layout__c = layout.Id;
        pContList[0].Page_Name__c =layout.Page_Types__c; 
        
        insert pContList;
        
        Placement_KOD__c pKod = new Placement_KOD__c(Placement_Content__c=pContList[0].Id,KOD__c=kodList[0].Id);
        insert pKod;
    }
    
    static testMethod void fetchKODDetails(){
        List<KOD__c> kodList = [SELECT Id FROM KOD__c LIMIT 2];
        Test.startTest();
        for(KOD__c kod : kodList){
            try{
                DGTL_MultiKODLinkController.fetchKODDetails(kod.Id);
            }catch(AuraException ae){
                System.debug('AuraException====='+ae.getMessage());
            }
        }
        Test.stopTest();
        try{
            DGTL_MultiKODLinkController.fetchKODDetails(kodList[0].Id+'a');
        }catch(AuraException ae){
            System.debug('AuraException====='+ae.getMessage());
        }
    }
    
    static testMethod void fetchPlacementKODs(){
        Placement_Content__c pc = [SELECT Id FROM Placement_Content__c LIMIT 1];
        Test.startTest();
        DGTL_MultiKODLinkController.fetchPlacementKODs(pc.Id);
        Test.stopTest();
    }
    
    static testMethod void linkPlacementKODs(){
        List<Id> kodIdAddList = new List<Id>();
        Id pcId = [SELECT Id FROM Placement_Content__c LIMIT 1].Id;
        for(KOD__c kod : [SELECT Id FROM KOD__c]){
            kodIdAddList.add(kod.Id);
        }
        List<Id> kodIdRemoveList = new List<Id>{[SELECT Id FROM KOD__c WHERE Offer_Status__c='Approved' LIMIT 1].Id};
        
        Test.startTest();
        DGTL_MultiKODLinkController.linkPlacementKODs(pcId, kodIdAddList, kodIdRemoveList);
        Test.stopTest();
        
        try{
            DGTL_MultiKODLinkController.linkPlacementKODs(pcId, new List<Id>(), new List<Id>{pcId});  //with wrong Id
        }catch(AuraException ae){
            System.debug('ae----'+ae.getMessage());
        }
        
        
    }

}