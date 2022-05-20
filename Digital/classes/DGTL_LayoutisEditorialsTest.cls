/************************************************************
Name          : DGTL_LayoutisEditorialsTest
Description   : Test Class for DGTL_LayoutisEditorials      
*************************************************************/
@isTest
public class DGTL_LayoutisEditorialsTest {
        @TestSetup
        static void datasetup(){
            Test.startTest();
            list<DGTL_Floorset_Plan__c> list_Floorset = new list<DGTL_Floorset_Plan__c>();
            list_Floorset.add(DGTL_TestDataFactory.createFloorsetPlan('VS',date.today(),'5 AM','Update'));
            list_Floorset.add(DGTL_TestDataFactory.createFloorsetPlan('VS',date.today()+4,'5 AM','Update'));
            insert  list_Floorset;
            Placement_Layout__c editorialLay =  DGTL_TestDataFactory.createPlacementLayout('VS','Editorials','Desktop',list_Floorset[1].Id, 'Layout');
            editorialLay.Collection_Page_Name__c = 'test editorial page';
            editorialLay.Collection_Page_Url__c = 'test editorial url';
            insert editorialLay;
            Test.stopTest();
        }
        static testmethod void fetchcontentTest1(){
            Test.startTest();
            list<DGTL_Floorset_Plan__c> list_floorset = [select id from DGTL_Floorset_Plan__c];
            Placement_Layout__c Editoriallay = [select id,Collection_Page_Name__c from Placement_Layout__c where Page_Types__c = 'Editorials'];
            map<string,string> map_Editorial = new map<string,string>();
            map_Editorial.put(string.valueOf(Editoriallay.Id),Editoriallay.Collection_Page_Name__c);
            system.assertEquals(map_Editorial, DGTL_LayoutisEditorials.fetchEditorialLayouts('VS','Editorials',string.valueOf(list_floorset[1].Id),'Desktop'));
            DGTL_LayoutisEditorials.fetchEditorial(String.valueOf(Editoriallay.Id));
            Test.stopTest();
        }
}