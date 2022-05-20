/************************************************************
Name          : DGTL_SearchContFromLibraryTest
Description   : Test Class for DGTL_SearchContFromLibrary      
*************************************************************/
@isTest
public class DGTL_SearchContFromLibraryTest {
    @TestSetup
        static void datasetup(){
            Test.startTest();
            list<DGTL_Floorset_Plan__c> list_Floorset = new list<DGTL_Floorset_Plan__c>();
            list_Floorset.add(DGTL_TestDataFactory.createFloorsetPlan('VS',date.today(),'5 AM','Update'));
            list_Floorset.add(DGTL_TestDataFactory.createFloorsetPlan('VS',date.today()+4,'5 AM','Update'));
            insert  list_Floorset;
            insert DGTL_TestDataFactory.createPlacementLayout('VS','Home Page','Desktop',list_Floorset[1].Id, 'Layout');
            Placement_Library__c lib = DGTL_TestDataFactory.createPlacementLibrary(DATE.today(), DATE.today()+1, 'VS', 'Home Page', '5 AM', '5 AM', 'Desktop', 'Approved', 'Non Offer', 'mainMsg');
            insert lib;
            insert DGTL_TestDataFactory.createPlacementContentDetail(null,string.valueOf(lib.Id),false,'Slide 1','assetPath','copy');
            Test.stopTest();
        }
    static testmethod void searchContFromLib(){
            Test.startTest(); 
            list<Placement_Library__c> lib = [select id,Brands__c,Page_Types__c,Start_Date__c,Main_Message__c from Placement_Library__c limit 1];
            list<string> list_selectedId = new list<String>();
            list_selectedId.add(string.valueOf(lib[0].Id));
            Placement_Layout__c lay = [select id,Test_Name__c from Placement_Layout__c where Page_Types__c = 'Home Page' limit 1];
            DGTL_SearchContFromLibrary.fetchFilterValues(); 
            DGTL_SearchContFromLibrary.fetchLibrary(lib[0]);
            //system.assertEquals(lib, DGTL_SearchContFromLibrary.fetchLibrary(lib[0]));
            DGTL_SearchContFromLibrary.getSelectedConts(list_selectedId, string.valueOf(lay.Id));
            DGTL_SearchContFromLibrary.getSelectedConts(list_selectedId, string.valueOf(lay.Id));
            Test.stopTest();
        }
}