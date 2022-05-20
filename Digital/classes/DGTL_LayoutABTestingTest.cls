/************************************************************
Name          : DGTL_LayoutisEditorialsTest
Description   : Test Class for DGTL_LayoutisEditorials      
*************************************************************/
@isTest
public class DGTL_LayoutABTestingTest {
    @TestSetup
        static void datasetup(){
            Test.startTest();
            list<DGTL_Floorset_Plan__c> list_Floorset = new list<DGTL_Floorset_Plan__c>();
            list_Floorset.add(DGTL_TestDataFactory.createFloorsetPlan('VS',date.today(),'5 AM','Update'));
            list_Floorset.add(DGTL_TestDataFactory.createFloorsetPlan('VS',date.today()+4,'5 AM','Update'));
            insert  list_Floorset;
            Placement_Layout__c ABTestingLay =  DGTL_TestDataFactory.createPlacementLayout('VS','Home Page','Desktop',list_Floorset[1].Id, 'Testing');
            ABTestingLay.Test_Name__c = 'ABTestingLay';
            insert ABTestingLay;
            List<Placement_Content__c> list_Contents = DGTL_TestDataFactory.createPlacementContentlist(ABTestingLay.Id,ABTestingLay.Page_Types__c, 1,null,'Some Message','Video','Controlled','Feature','Non Offer');   
            insert list_Contents;
            insert DGTL_TestDataFactory.createPlacementContentDetail(list_Contents[0].Id);
            Test.stopTest();
        }
        static testmethod void ABTest(){
            Test.startTest();
            list<DGTL_Floorset_Plan__c> list_floorset = [select id from DGTL_Floorset_Plan__c];
            List<Placement_Content__c> list_Contents = [select id,Name from Placement_Content__c];
            Placement_Layout__c ABlay = [select id,Test_Name__c from Placement_Layout__c where Page_Types__c = 'Home Page'];
            map<string,string> map_ABlay = new map<string,string>();
            map_ABlay.put(string.valueOf(ABlay.Id),ABlay.Test_Name__c);
            system.assertEquals(map_ABlay, DGTL_LayoutABTesting.fetchABTestLayouts('VS','Home Page',string.valueOf(list_floorset[1].Id),'Desktop'));
            DGTL_LayoutABTesting.createTestLayout('VS','Home Page',string.valueOf(list_floorset[1].Id),'Desktop', 'pageName', string.valueOf(ABlay.Id), list_Contents);
            DGTL_LayoutABTesting.createTestLayout('VS','Home Page',string.valueOf(list_floorset[0].Id),'Desktop', 'pageName 22', '', list_Contents);
            Test.stopTest();
        }

}