/************************************************************
Name          : DGTL_CloneLayoutContentTest
Description   : Test Class for DGTL_CloneLayoutContent      
*************************************************************/
@isTest
public class DGTL_CloneLayoutContentTest {
 @TestSetup
        static void datasetup(){
            Test.startTest();
             list<DGTL_Floorset_Plan__c> list_Floorset = new list<DGTL_Floorset_Plan__c>();
            list_Floorset.add(DGTL_TestDataFactory.createFloorsetPlan('VS',date.today(),'5 AM','Update'));
            list_Floorset.add(DGTL_TestDataFactory.createFloorsetPlan('VS',date.today()+4,'5 AM','Update'));
            list_Floorset[0].Minute__c = null;
            list_Floorset[1].Minute__c = '10';
            insert  list_Floorset;
            update  list_Floorset;
            list<Placement_Library__c> list_library = new list<Placement_Library__c>();
            list_library.add(DGTL_TestDataFactory.createPlacementLibrary(DATE.today(), DATE.today()+1, 'VS', 'Home Page', '5 AM', '5 AM', 'Desktop', 'Approved', 'Non Offer', 'mainMsg'));
            list_library.add(DGTL_TestDataFactory.createPlacementLibrary(DATE.today(), DATE.today()+2, 'VS', 'Home Page', '5 AM', '9 AM', 'Desktop', 'Approved', 'Non Offer', 'mainMsg2')); 
            list_library.add(DGTL_TestDataFactory.createPlacementLibrary(DATE.today(), DATE.today()+1, 'VS', 'Editorials', '5 AM', '5 AM', 'Desktop', 'Approved', 'Non Offer', 'mainMsg3'));
            list_library[0].Start_Minute__c = null;
            list_library[0].End_Minute__c = null;
            list_library[0].Placement_type__c = 'cue';
            list_library[0].Collection_Page_Url__c = 'collection page url test';
            list_library[2].Editorial_Name__c = 'Edt name Clone';
            list_library[2].Placement_type__c = 'cue';
            insert list_library;
            insert DGTL_TestDataFactory.createPlacementContentDetail(null,string.valueOf(list_library[0].Id),false,'Slide 1','assetPath','copy');
            Placement_Library__c clonelib = list_library[0].clone();
            insert clonelib;
            list<Placement_Layout__c> list_layout = new list<Placement_Layout__c>();
            list_layout.add(DGTL_TestDataFactory.createPlacementLayout('VS','Home Page','Desktop',list_Floorset[1].Id, 'Layout'));
            list_layout.add(DGTL_TestDataFactory.createPlacementLayout('VS','Sport LP','Desktop',list_Floorset[1].Id, 'Layout'));
            list_layout.add(DGTL_TestDataFactory.createPlacementLayout('VS','Editorials','Desktop',list_Floorset[1].Id, 'Layout'));
            list_layout[2].Collection_Page_Name__c = 'Editorial Page test';
            insert list_layout;
            List<Placement_Content__c> list_Contents = DGTL_TestDataFactory.createPlacementContentlist(list_layout[0].Id,list_layout[0].Page_Types__c, 1,null,'Some Message','Video','Controlled','Feature','Non Offer');      
            list_Contents[0].Content_Type__c = 'Carousel';
            insert list_Contents;
            Test.stopTest();
        }
    static testmethod void CloneContentsTest(){
        Test.startTest();
        list<DGTL_Floorset_Plan__c> list_floorset = [select id from DGTL_Floorset_Plan__c];
        list<string> list_floorsetIds = new list<string>();
        Placement_Layout__c lay = new Placement_Layout__c(Brands__c = 'VS',Page_Types__c = 'Home Page',Device_Type__c = 'Desktop',Floorset_Plan__c =list_floorset[0].Id);
        Placement_Layout__c lay2 = new Placement_Layout__c(Brands__c = 'VS',Page_Types__c = 'Editorials',Device_Type__c = 'Desktop',Floorset_Plan__c =list_floorset[1].Id);
        list<Placement_Layout__c> list_layout = new list<Placement_Layout__c>();
        list_layout.add(lay);
        list_layout.add(lay2);
        
        List<String> PageTypes = new List<String> ();
        PageTypes.add('Home Page');PageTypes.add('Editorials');
        List<String> deviceTypes = new List<String> ();
        deviceTypes.add('Desktop'); deviceTypes.add('Mobile');
        
        DGTL_CloneLayoutContent.fetchFloorsetWrapper(lay,date.today()-10,date.today()+10,PageTypes,deviceTypes);
        DGTL_CloneLayoutContent.fetchFloorsetWrapper(lay2,date.today()-10,date.today()+10,PageTypes,deviceTypes);
        for(DGTL_Floorset_Plan__c flr : list_floorset){
            list_floorsetIds.add(string.valueof(flr.Id));
        }
        list<Placement_Content__c> lst_Con = Database.query(DGTL_DataAccessor.getSobjectSoql(new Placement_Content__c()));
        Placement_Content_Detail__c contdet = new Placement_Content_Detail__c();
        contdet.Placement_Content__c = lst_Con[0].Id;
        insert contdet;
        DGTL_CloneLayoutContent.cloneContentsToLayout(lst_Con,lay2,list_layout);
        DGTL_CloneLayoutContent.cloneContentsToLayout(lst_Con,lay,list_layout);
        DGTL_CloneLayoutContent.getDependentMap(lay,'Brands__c','Page_Types__c');
        Test.stopTest();
        }
}