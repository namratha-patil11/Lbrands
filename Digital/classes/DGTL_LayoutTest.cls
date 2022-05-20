/************************************************************
Name          : DGTL_LayoutTest
Description   : Test Class for DGTL_Layout      
*************************************************************/
@isTest
public class DGTL_LayoutTest {
 
        @TestSetup
        static void datasetup(){
            Test.startTest();
            list<DGTL_ErrorMessages__c> list_errorMsg = new list<DGTL_ErrorMessages__c>();
            list_errorMsg.add(DGTL_TestDataFactory.createErrorMessages('DGtL_ABTesting_TestWithoutContent', 'Cannot save Test without selecting contents'));
            list_errorMsg.add(DGTL_TestDataFactory.createErrorMessages('DGTL_LayoutNoFloorsetPlan', 'No Floorset Plans for Next/Previous Update'));
            list_errorMsg.add(DGTL_TestDataFactory.createErrorMessages('DGTL_Main_NoAccessMang', 'You dont have access, please check with system administrator'));
            list_errorMsg.add(DGTL_TestDataFactory.createErrorMessages('DGTL_Main_NoPlaceConts', 'No applicable placements/layout for selected update.Please create one as needed'));
            list_errorMsg.add(DGTL_TestDataFactory.createErrorMessages('DGTL_NoLayout', 'Layout does not exists'));
            list_errorMsg.add(DGTL_TestDataFactory.createErrorMessages('DGTL_NotAbleToDeleteLayout', 'Deleting layout failed!! Please contact system administrator.'));
            list_errorMsg.add(DGTL_TestDataFactory.createErrorMessages('DGTL_SameLayout', 'You are trying to search with same layout'));
            list_errorMsg.add(DGTL_TestDataFactory.createErrorMessages('LayoutUnsavedContentAlert', 'You have unsaved contents, do you want to proceed'));
            list_errorMsg.add(DGTL_TestDataFactory.createErrorMessages('DGTL_DuplicateLayoutorContent', '"Content or Layout" already exists for selected Floorset/Update!'));
            list_errorMsg.add(DGTL_TestDataFactory.createErrorMessages('DGTL_LayoutNoFloorsetPlanNext', 'No applicable Floorset/Update for next update. Please create one as needed'));
            list_errorMsg.add(DGTL_TestDataFactory.createErrorMessages('DGTL_LayoutNoFloorsetPlanPrevious', 'No applicable Floorset/Update for previous update. Please create one as needed'));
            list_errorMsg.add(DGTL_TestDataFactory.createErrorMessages('DGTL_LayoutNoPlaceContsNext', 'No applicable placements/layout for next update. Please create one as needed'));
            list_errorMsg.add(DGTL_TestDataFactory.createErrorMessages('DGTL_LayoutNoPlaceContsPrevious', 'No applicable placements/layout for previous update. Please create one as needed'));
            insert list_errorMsg;
            
            Id fieldAccessId = Schema.SObjectType.DGTL_Access_Management__c.getRecordTypeInfosByName().get('Field Access').getRecordTypeId();
            list<DGTL_Access_Management__c> list_AccessMng = new list<DGTL_Access_Management__c>();
            list_AccessMng.add(DGTL_TestDataFactory.createAccessManagment('VS','Placement_Content__c','Image__c;Link__c;Main_Message__c;Offer_Type__c','Image__c;Link__c;Main_Message__c;Offer_Type__c','','DGTL Main',fieldAccessId,'DGTL_Merchandiser'));
            list_AccessMng.add(DGTL_TestDataFactory.createAccessManagment('VS','Placement_Content_Detail__c','Asset_Path__c;Copy__c;Is_Deleted__c','Asset_Path__c;Copy__c','','Layout - Content Details',fieldAccessId,'DGTL_Merchandiser'));
            list_AccessMng[0].MiniView_RO_Fields__c = 'Offer_Type__c;Shot_Number__c';            
            list_AccessMng[0].Button__c = 'clone;Create - Layout;Cascade;Comment - Content;History - Content;Update Content;Create AB Test;Create Takedown;Add KOD;Create Contingency';
            insert list_AccessMng;
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
            list_library[2].Editorial_Name__c = 'Edt name';
            list_library[2].Placement_type__c = 'Feature';
            insert list_library;
            update list_library;
            insert DGTL_TestDataFactory.createPlacementContentDetail(null,string.valueOf(list_library[0].Id),false,'Slide 1','assetPath','copy');
            insert DGTL_TestDataFactory.createPlacementContentDetail(null,string.valueOf(list_library[0].Id),false,'','','');
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
            insert list_Contents;
            list<Digital_Live_Users__c> list_LiveUsers = new list<Digital_Live_Users__c>();
            list_LiveUsers.add(DGTL_TestDataFactory.createLiveUser(list_layout[0].Id,system.now()));
            list_LiveUsers.add(DGTL_TestDataFactory.createLiveUser(list_layout[1].Id,system.now()));
            list_LiveUsers.add(DGTL_TestDataFactory.createLiveUser(list_layout[2].Id,system.now()));
            insert list_LiveUsers;
            Test.stopTest();
            
        }
    static testmethod void fetchcontentTest1(){
        Test.startTest();         
        Profile objprofile = [select id from Profile where Name='DGTL Base Profile'];
            user merUser = DGTL_TestDataFactory.createUser(objprofile.Id,'DGTL_Merchandiser');
            merUser.DGTL_Brands__c = 'VS';
            insert merUser;
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'DGTL_Domestic_User'];
            PermissionSetAssignment psAssign = DGTL_TestDataFactory.createPermissionSetAssgn(merUser.Id,ps.Id);
            insert psAssign;
        System.runAs(merUser){
            list<Digital_Live_Users__c> list_LiveUsers = [select id,User__c,User__r.Name,Layout__c from Digital_Live_Users__c];
            list_LiveUsers[0].User__c = merUser.Id;
            list_LiveUsers[1].User__c = merUser.Id;
            list_LiveUsers[2].User__c = merUser.Id;
            update list_LiveUsers;            
            list<DGTL_Floorset_Plan__c> list_floorset = [select id from DGTL_Floorset_Plan__c];
            Placement_Layout__c Editoriallay = [select id,Brands__c,Page_Types__c,Device_Type__c,Floorset_Plan__c,Collection_Page_Name__c from Placement_Layout__c where Page_Types__c = 'Editorials'];
            map<string,string> map_Editorial = new map<string,string>();
            map_Editorial.put(string.valueOf(Editoriallay.Id),Editoriallay.Collection_Page_Name__c);
            system.assertEquals(map_Editorial, DGTL_Layout.fetchEditorialLayouts('VS','Editorials',string.valueOf(list_floorset[1].Id),'Desktop'));
            
            Placement_Layout__c lay = new Placement_Layout__c(Brands__c = 'VS',Page_Types__c = 'Home Page',Device_Type__c = 'Desktop',Floorset_Plan__c =list_floorset[0].Id,Compared_Placement_Layout__c=Editoriallay.Id);
            Placement_Layout__c lay2 = new Placement_Layout__c(Brands__c = 'VS',Page_Types__c = 'Home Page',Device_Type__c = 'Desktop',Floorset_Plan__c =list_floorset[1].Id);
            DGTL_Layout.fetchContents(lay,'Search',false,'');
           // DGTL_Layout.fetchContents(lay,'Next Update',false,'');
            DGTL_Layout.fetchContents(lay,'Previous Update',false,'');            
            DGTL_Layout.fetchContents(lay2,'Search',false,'');
            DGTL_Layout.fetchContents(Editoriallay,'Next Update',false,'');
            DGTL_Layout.currentUserDetails();
            DGTL_Layout.getCurrentUserDetails();
            List<Placement_Content__c> list_RemovedContent = new List<Placement_Content__c>();
            DGTL_Layout.finalSubmitContent(lay, '', DGTL_Layout.fetchContents(lay,'Search',false,'').list_contentWpr, list_RemovedContent,false);
            DGTL_Layout.finalSubmitContent(lay2, '', DGTL_Layout.fetchContents(lay2,'Search',false,'').list_contentWpr, null,true);
            Id floorsetId = list_floorset[1].id;
            Placement_Layout__c searchlay = [select id,Brands__c,Page_Types__c,Device_Type__c,Floorset_Plan__c from Placement_Layout__c where Floorset_Plan__c=:floorsetId limit 1];
            DGTL_Layout.searchSelectedContFromExistingLayout(searchlay, '');
            DGTL_Layout.fetchContents(lay2,'Next Update',false,'');
            Placement_Layout__c clonelay = new Placement_Layout__c(Brands__c = 'VS',Page_Types__c = 'Panties LP',Device_Type__c = 'Desktop',Floorset_Plan__c =list_floorset[1].Id);
            
            List<Placement_Content__c> list_clonecont = [select id from Placement_Content__c];
            DGTL_Layout.cloneSave(clonelay, list_clonecont);
            DGTL_Layout.cloneSave(clonelay, list_clonecont);
            DGTL_Layout.saveSelectedContFromExistingLayout(list_clonecont, string.valueOf(searchlay.Id), 'AB Test', 'AB Test AB Test',true);
            Placement_Layout__c disablePlacementLayout = [select id,Brands__c,Page_Types__c,Device_Type__c,Floorset_Plan__c from Placement_Layout__c where Page_Types__c='Sport LP' limit 1];
            Id layexcid = disablePlacementLayout.Id;
            system.assertEquals('SUCCESS', DGTL_Layout.disablePlacementLayout(disablePlacementLayout));
            lay.Id = layexcid;
           /*  //create Placement KOD
            Placement_Library__c plibrary = DGTL_TestDataFactory.createPlacementLibrary(DATE.today().addDays(-1), DATE.today().addDays(1), 'VS', 'Home Page', '1 AM', '6 AM', 'Desktop', 'Approved', 'Offer', 'Main Message - Desktop');
            insert plibrary;
            
            //create placement contents
            List<Placement_Content__c> pContList1 = DGTL_TestDataFactory.createPlacementContentlist(null,'', 1,
                                                                                                    null,'','Video',
                                                                                                    'Controlled','Feature','Offer');
            //update
            pContList1[0].S_No__c = 1;
            pContList1[0].Placement_Library__c = plibrary.Id;
            pContList1[0].Main_Message__c = 'Main Message 1 - Desktop';
            pContList1[0].Placement_Layout__c = lay.Id;
            pContList1[0].Page_Name__c =lay.Page_Types__c;
            insert pContList1;
            
            Kod__c kod = new KOD__c(Offer_Status__c='Approved',Name='Test1');
            insert kod;
            
             Placement_KOD__c pKOD = new Placement_KOD__c(Placement_Content__c = pContList1[0].Id, KOD__c = kod.Id);
            insert pKOD;
             DGTL_Layout.fetchContents(lay,'Search',false,'');*/
            
            //delete disablePlacementLayout;
            //system.assertNotEquals('SUCCESS', DGTL_Layout.disablePlacementLayout(lay));
            list_RemovedContent = [select id from Placement_Content__c];
            delete list_RemovedContent;

            DGTL_Layout.fetchContents(lay,'Search',false,'');
            lay.Brands__c = 'PINK';
            DGTL_Layout.fetchContents(lay,'Search',false,'');
            system.assertEquals('VS', DGTL_Layout.getUserBrandHpr());
            DGTL_Layout.digitalLiveUsers(string.valueof(Editoriallay.Id));
            delete list_LiveUsers;
            DGTL_Layout.digitalLiveUsers(string.valueof(Editoriallay.Id));
            DGTL_Layout.deleteLiveUsers(string.valueOf(Editoriallay.Id));
            Placement_Layout__c layLastModified = [select Id,Name,LastModifiedById,LastModifiedBy.Name,LastModifiedDate from Placement_Layout__c limit 1];
            DGTL_Layout.getLastModified(string.valueof(layLastModified.Id));
            DGTL_Tickets__c objticket = new DGTL_Tickets__c();
            objticket.RecordTypeId = Schema.SObjectType.DGTL_Tickets__c.getRecordTypeInfosByName().get('Data Issues').getRecordTypeId();
            DGTL_Layout.saveTicket(objticket);
           // DGTL_Layout.finalSubmitContent(lay, '', DGTL_Layout.fetchContents(lay,'Search',false).list_contentWpr, list_RemovedContent);
            
         }   
        DGTL_Layout.getDataIssuesRecordTypeID();
        Test.stopTest();
    }
    
    static testmethod void floorsetupdate(){
        list<DGTL_Floorset_Plan__c> list_Floorset = [select id,Brands__c,Date__c from DGTL_Floorset_Plan__c ] ;
        list_Floorset[0].Date__c = list_Floorset[0].Date__c+1;
        update list_Floorset;
        DGTLFloorsetPlanTriggerHandler cls = new DGTLFloorsetPlanTriggerHandler();
        cls.BeforeDelete();
        cls.AfterInsert();
        cls.AfterUpdate();
        cls.AfterDelete();
        cls.AfterUndelete();
        Placement_Layout__c lay2 = new Placement_Layout__c(Brands__c = 'VS',Page_Types__c = 'Home Page',Device_Type__c = 'Desktop',Floorset_Plan__c =list_floorset[1].Id);
        Placement_Layout__c lay = new Placement_Layout__c(Brands__c = 'VS',Page_Types__c = 'Home Page',Device_Type__c = 'Desktop',Floorset_Plan__c =list_floorset[0].Id);
        DGTL_Layout.fetchContents(lay2,'Previous Update',false,'');
        list<Placement_Layout__c> list_layout = [select id from Placement_Layout__c];
        DGTL_Layout.getLayoutInfo(list_layout[0].id);
        delete list_layout;
        list<Placement_Library__c> list_library = [select id from Placement_Library__c];
        delete list_library;
        DGTL_Layout.fetchContents(lay2,'Previous Update',false,'');        
        DGTL_Layout.fetchContents(lay2,'Search',false,'');
    }
    
    static testmethod void codecoverageEditorial(){        
        Profile objprofile = [select id from Profile where Name='DGTL Base Profile'];
            user merUser = DGTL_TestDataFactory.createUser(objprofile.Id,'DGTL_Merchandiser');
            merUser.DGTL_Brands__c = 'VS';
            insert merUser;
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'DGTL_Domestic_User'];
            PermissionSetAssignment psAssign = DGTL_TestDataFactory.createPermissionSetAssgn(merUser.Id,ps.Id);
            insert psAssign;
        System.runAs(merUser){
        Test.startTest();
        	Placement_Layout__c Editoriallay = [select id,Brands__c,Page_Types__c,Device_Type__c,Floorset_Plan__c,Collection_Page_Name__c from Placement_Layout__c where Page_Types__c = 'Editorials'];
        	DGTL_Layout.fetchContents(Editoriallay,'Search',false,'');
            DGTL_Layout.fetchContents(Editoriallay,'Next Update',false,'');
            DGTL_Layout.fetchContents(Editoriallay,'Previous Update',false,'');
        Test.stopTest();
        }
    }
}