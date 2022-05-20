@isTest
public class DGTL_KODTriggerHandlerTest {
    
    @testSetup
    static void setupData(){
        Id userTaskRecordTypeId = [SELECT Id,DeveloperName FROM RecordType WHERE sObjectType='DGTL_Task__c' AND  DeveloperName='User_Task'].Id;
        
        KOD__c kod = new KOD__c(Name='Test KOD');
        insert kod;
        
        DGTL_Floorset_Plan__c vsFloorsetPlan = DGTL_TestDataFactory.createFloorsetPlan('VS',DATE.today().addDays(1),'2 AM','Update');
        insert vsFloorsetPlan;
        
        Placement_Layout__c layout = DGTL_TestDataFactory.createPlacementLayout('VS','Home Page','Desktop',vsFloorsetPlan.Id, 'Layout');
        insert layout;
        
        //create placement contents
       List<Placement_Content__c> pContList = DGTL_TestDataFactory.createPlacementContentlist(null,'', 1,
                                                                                                 null,'','Video',
                                                                                                  'Controlled','Feature','Offer');
        pContList[0].Placement_Layout__c = layout.Id;
        pContList[0].KOD__c = kod.Id;
        insert pContList;
        
        Placement_KOD__c pKod = new Placement_KOD__c(KOD__c=kod.Id, Placement_Content__c=pContList[0].Id);
        insert pKod;
        
        DGTL_Task__c digitalTask = new DGTL_Task__c();
        digitalTask.RecordTypeId = userTaskRecordTypeId;
        digitalTask.Placement_Content__c = pContList[0].Id;
        digitalTask.Status__c = 'New';
        
        insert digitalTask;
        
    }
    
    public static testMethod void handleKODStatusChangeTest(){
        KOD__c kod = [SELECT Id,Offer_Status__c FROM KOD__c LIMIT 1];
        
        Test.startTest();
        kod.Offer_Status__c = 'Cancelled';
        update kod;
        Test.stopTest();
    }

}