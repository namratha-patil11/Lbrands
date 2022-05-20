@isTest
public class DGTL_MultiContentEdtiTest {
      @TestSetup
        static void datasetup(){
            Test.startTest();
            insert DGTL_TestDataFactory.createErrorMessages('DGTL_DuplicateLayoutorContent', '"Content or Layout" already exists for selected Floorset/Update!');
            list<DGTL_Floorset_Plan__c> list_Floorset = new list<DGTL_Floorset_Plan__c>();
            list_Floorset.add(DGTL_TestDataFactory.createFloorsetPlan('VS',date.today(),'5 AM','Update'));
            list_Floorset.add(DGTL_TestDataFactory.createFloorsetPlan('VS',date.today()+4,'5 AM','Update'));
            list_Floorset[0].Minute__c = null;
            list_Floorset[1].Minute__c = '10';
            insert  list_Floorset;
            Id fieldAccessId = Schema.SObjectType.DGTL_Access_Management__c.getRecordTypeInfosByName().get('Field Access').getRecordTypeId();
            list<DGTL_Access_Management__c> list_AccessMng = new list<DGTL_Access_Management__c>();
            list_AccessMng.add(DGTL_TestDataFactory.createAccessManagment('VS','Placement_Content__c','Image__c;Link__c;Main_Message__c;Offer_Type__c','Image__c;Link__c;Main_Message__c;Offer_Type__c','','DGTL Main',fieldAccessId,'DGTL_Merchandiser'));
            list_AccessMng.add(DGTL_TestDataFactory.createAccessManagment('VS','Placement_Content_Detail__c','Asset_Path__c;Copy__c;Is_Deleted__c','Asset_Path__c;Copy__c','','Layout - Content Details',fieldAccessId,'DGTL_Merchandiser'));
            list_AccessMng[0].Page_Type__c = 'Home Page';
            list_AccessMng[1].Page_Type__c = 'Home Page';
            insert list_AccessMng;
            
            list<Placement_Library__c> list_library = new list<Placement_Library__c>();
            list_library.add(DGTL_TestDataFactory.createPlacementLibrary(DATE.today(), DATE.today()+1, 'VS', 'Home Page', '5 AM', '5 AM', 'Desktop', 'Approved', 'Non Offer', 'mainMsg'));
            list_library.add(DGTL_TestDataFactory.createPlacementLibrary(DATE.today(), DATE.today()+2, 'VS', 'Home Page', '5 AM', '9 AM', 'Desktop', 'Approved', 'Non Offer', 'mainMsg2')); 
            list_library.add(DGTL_TestDataFactory.createPlacementLibrary(DATE.today(), DATE.today()+1, 'VS', 'Editorials', '5 AM', '5 AM', 'Desktop', 'Approved', 'Non Offer', 'mainMsg3'));
            list_library[0].Start_Minute__c = null;
            list_library[0].End_Minute__c = null;
            list_library[0].Placement_type__c = 'cue';
            list_library[0].Collection_Page_Url__c = 'collection page url test';
            list_library[2].Editorial_Name__c = 'Edt name multicontentclone';
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
            list_layout[0].Collection_Page_Name__c = 'Editorial Page test';
            insert list_layout;
            //update list_layout;            
            List<Placement_Content__c> list_Contents = DGTL_TestDataFactory.createPlacementContentlist(list_layout[0].Id,list_layout[0].Page_Types__c, 1,null,'Some Message','Video','Controlled','Feature','Non Offer');      
            list_Contents[0].Content_Type__c = 'Carousel';
            list_Contents[0].Placement_Library__c = list_library[0].Id;
            insert list_Contents;
            list<Placement_Content_Detail__c> list_contDet = new list<Placement_Content_Detail__c>();
            list_contDet.add(DGTL_TestDataFactory.createPlacementContentDetail(string.valueOf(list_Contents[0].Id),string.valueOf(list_library[0].Id),false,'Slide 1','Asset Path','Copytest'));
            list_contDet.add(DGTL_TestDataFactory.createPlacementContentDetail(string.valueOf(list_Contents[0].Id),string.valueOf(list_library[0].Id),false,'Slide 2','Asset Path3','Copytest3'));
            insert list_contDet;
            Test.stopTest(); 
            
        }
    static testMethod void multiContentEditTest(){
        Test.startTest();         
        Profile objprofile = [select id from Profile where Name='DGTL Base Profile'];
            user merUser = DGTL_TestDataFactory.createUser(objprofile.Id,'DGTL_Merchandiser');
            merUser.DGTL_Brands__c = 'VS';
            insert merUser;
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'DGTL_Merchandiser'];
            PermissionSetAssignment psAssign = DGTL_TestDataFactory.createPermissionSetAssgn(merUser.Id,ps.Id);
            insert psAssign;
        System.runAs(merUser){       //list_contentWpr
        	list<Placement_Library__c> list_library = [select id,Name from Placement_Library__c];
        	DGTL_MulticntEditController.fetchContents(string.valueOf(list_library[0].Id));
            DGTL_MulticntEditController.finalSubmitContent(DGTL_MulticntEditController.fetchContents(string.valueOf(list_library[0].Id)).list_contentWpr);
        }
        Test.stopTest();
    } 

}