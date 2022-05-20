@isTest
public class DGTL_WebRemoterTest {
    
    @TestSetup
    static void datasetup(){
        DGTL_Floorset_Plan__c fp = DGTL_TestDataFactory.createFloorsetPlan('VS',date.today(),'5 AM','Update');
        insert fp;
        
        Placement_Library__c pl = DGTL_TestDataFactory.createPlacementLibrary(DATE.today(), DATE.today()+1, 'VS', 'Home Page', '5 AM', '5 AM', 'Desktop', 'Approved', 'Non Offer', 'mainMsg');
        insert pl;
        
        Placement_Layout__c layout = DGTL_TestDataFactory.createPlacementLayout('VS','Home Page','Desktop',fp.Id, 'Layout');
        insert layout;
        
        List<Placement_Content__c> list_Contents = DGTL_TestDataFactory.createPlacementContentlist(layout.Id,layout.Page_Types__c, 1,null,'Some Message','Video','Controlled','Feature','Non Offer');
        insert list_Contents;
    }
    
    static testMethod void getFutureContents(){
        Id plcId = [SELECT Id FROM Placement_Content__c LIMIT 1].Id;
        DGTL_WebRemoter.getFutureContents(plcId);
    }

}