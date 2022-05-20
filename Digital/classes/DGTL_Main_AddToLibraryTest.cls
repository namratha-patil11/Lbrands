/************************************************************
Name          : DGTL_Main_AddToLibraryTest
Description   : Test Class for DGTL_Main_AddToLibrary      
*************************************************************/
@isTest
public class DGTL_Main_AddToLibraryTest {
     @TestSetup
        static void datasetup(){
            Test.startTest();
            list<DGTL_Floorset_Plan__c> list_Floorset = new list<DGTL_Floorset_Plan__c>();
            list_Floorset.add(DGTL_TestDataFactory.createFloorsetPlan('VS',date.today(),'5 AM','Update'));
            list_Floorset.add(DGTL_TestDataFactory.createFloorsetPlan('VS',date.today()+4,'5 AM','Update'));
            insert  list_Floorset;
            insert DGTL_TestDataFactory.createPlacementLibrary(DATE.today(), DATE.today()+1, 'VS', 'Home Page', '5 AM', '5 AM', 'Desktop', 'Approved', 'Non Offer', 'mainMsg');
            insert DGTL_TestDataFactory.createPlacementLayout('VS','Home Page','Desktop',list_Floorset[1].Id, 'Layout');
            Test.stopTest();
        }
        static testmethod void AddToLibrary(){
            Test.startTest(); 
            Placement_Library__c lib = [select id from Placement_Library__c limit 1];
            Placement_Layout__c lay = [select id,Test_Name__c from Placement_Layout__c where Page_Types__c = 'Home Page' limit 1];
            DGTL_Main_AddToLibrary.fetchlibFields();
            DGTL_Main_AddToLibrary.createLibAndContent(string.valueOf(lib.Id), string.valueOf(lay.Id));
            DGTL_Main_AddToLibrary.createLibAndContent(string.valueOf(lay.Id),string.valueOf(lib.Id));
            Test.stopTest();
        }

}