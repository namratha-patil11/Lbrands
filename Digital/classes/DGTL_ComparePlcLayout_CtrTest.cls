@isTest
public class DGTL_ComparePlcLayout_CtrTest {
    
    @testSetup
    static void setupData(){
        Id compareRecordTypeId = Schema.SObjectType.DGTL_Access_Management__c.getRecordTypeInfosByName().get('Compare Setup').getRecordTypeId();
        Id viewRecordTypeId = Schema.SObjectType.DGTL_Access_Management__c.getRecordTypeInfosByName().get('View Management').getRecordTypeId();
        
        //create access management for view
        DGTL_Access_Management__c accessMgmtforView = DGTL_TestDataFactory.createAccessManagment('VS','Placement_Content__c','Link__c;Main_Message__c;Offer_Type__c','Link__c','','',viewRecordTypeId,'DGTL_Merchandiser');
        accessMgmtforView.UserOrProfileId__c = UserInfo.getUserId();
        accessMgmtforView.Tab_Name__c = 'DGTL View';
        insert accessMgmtforView;
        
        DGTL_Access_Management__c accessMgmtforView1 = DGTL_TestDataFactory.createAccessManagment('VS','Placement_Content_Detail__c','Copy__c;Link_Text__c;Sub_Type__c;Slides__c','Copy__c','','',viewRecordTypeId,'DGTL_Merchandiser');
        accessMgmtforView1.UserOrProfileId__c = UserInfo.getUserId();
        accessMgmtforView1.Tab_Name__c = 'DGTL View';
        insert accessMgmtforView1;
        
        //create access management for compare
        DGTL_Access_Management__c accessMgmtforCompare = DGTL_TestDataFactory.createAccessManagment('VS','Placement_Content__c','Main_Message__c','Main_Message__c','','',compareRecordTypeId,'DGTL_Merchandiser');
        insert accessMgmtforCompare ;
        
        //create custtom settings
        DGTL_ErrorMessages__c errMsg = DGTL_TestDataFactory.createErrorMessages('DGTL_Main_NoPlaceConts','No Placements in the library for the selected floorset');
        insert errMsg;
            
        //create floorset plans
        List<DGTL_Floorset_Plan__c> fPlanList = new List<DGTL_Floorset_Plan__c>();
        
        DGTL_Floorset_Plan__c vsFloorsetPlan1 = DGTL_TestDataFactory.createFloorsetPlan('VS',DATE.today(),'2 AM','Update');
        fPlanList.add(vsFloorsetPlan1);
        DGTL_Floorset_Plan__c vsFloorsetPlan2 = DGTL_TestDataFactory.createFloorsetPlan('VS',DATE.today(),'5 AM','Update');
        fPlanList.add(vsFloorsetPlan2);
        DGTL_Floorset_Plan__c vsFloorsetPlan3 = DGTL_TestDataFactory.createFloorsetPlan('VS',DATE.today().addDays(1),'5 AM','Update');
        fPlanList.add(vsFloorsetPlan3);
        
        insert fPlanList;
        
        // create placement layouts
        List<Placement_Layout__c> pLayoutList = new List<Placement_Layout__c>();
        
        Placement_Layout__c layout1 = DGTL_TestDataFactory.createPlacementLayout('VS','Home Page','Desktop',vsFloorsetPlan1.Id, 'Layout');
        pLayoutList.add(layout1);
        Placement_Layout__c layout2 = DGTL_TestDataFactory.createPlacementLayout('VS','Home Page','Desktop',vsFloorsetPlan2.Id, 'Layout');
        pLayoutList.add(layout2);
        Placement_Layout__c layout3 = DGTL_TestDataFactory.createPlacementLayout('VS','Home Page','Desktop',vsFloorsetPlan3.Id, 'Layout');
        pLayoutList.add(layout3);
        
        insert pLayoutList;
        
        //create placement libraries
        List<Placement_Library__c> pLibraryList = new List<Placement_Library__c>();
        
        Placement_Library__c plibrary1 = DGTL_TestDataFactory.createPlacementLibrary(DATE.today().addDays(-1), DATE.today().addDays(1), 'VS', 'Home Page', '1 AM', '6 AM', 'Desktop', 'Approved', 'Offer', 'Main Message - Desktop');
        pLibraryList.add(plibrary1);
        Placement_Library__c plibrary2 = DGTL_TestDataFactory.createPlacementLibrary(DATE.today().addDays(-1), DATE.today().addDays(1), 'VS', 'Home Page', '1 AM', '6 AM', 'Mobile', 'Approved', 'Offer', 'Main Message - Mobile');
        pLibraryList.add(plibrary2);
        Placement_Library__c plibrary3 = DGTL_TestDataFactory.createPlacementLibrary(DATE.today().addDays(-1), DATE.today().addDays(1), 'VS', 'Home Page', '1 AM', '6 AM', 'Desktop', 'Approved', 'Offer', 'Main Message - Desktop');
        pLibraryList.add(plibrary3);
        Placement_Library__c plibrary4 = DGTL_TestDataFactory.createPlacementLibrary(DATE.today().addDays(-1), DATE.today().addDays(1), 'VS', 'Home Page', '1 AM', '6 AM', 'Desktop', 'Approved', 'Offer', 'Main Message - Desktop');
        pLibraryList.add(plibrary4);
        Placement_Library__c plibrary5 = DGTL_TestDataFactory.createPlacementLibrary(DATE.today().addDays(-1), DATE.today().addDays(1), 'VS', 'Home Page', '1 AM', '6 AM', 'Desktop', 'Approved', 'Offer', 'Main Message - Desktop');
        pLibraryList.add(plibrary5);
        Placement_Library__c plibrary6 = DGTL_TestDataFactory.createPlacementLibrary(DATE.today().addDays(-1), DATE.today().addDays(1), 'VS', 'Home Page', '1 AM', '6 AM', 'Desktop', 'Approved', 'Offer', 'Main Message - Desktop');
        pLibraryList.add(plibrary6);
        Placement_Library__c plibrary7 = DGTL_TestDataFactory.createPlacementLibrary(DATE.today().addDays(-1), DATE.today().addDays(1), 'VS', 'Home Page', '1 AM', '6 AM', 'Desktop', 'Approved', 'Offer', 'Main Message - Desktop');
        pLibraryList.add(plibrary7);
        
        insert pLibraryList;
        
        //create placement contents
       List<Placement_Content__c> pContList1 = DGTL_TestDataFactory.createPlacementContentlist(null,'', 13,
                                                                                                 null,'','Video',
                                                                                                  'Controlled','Feature','Offer');
        //update
        pContList1[0].S_No__c = 1;
        pContList1[0].Placement_Library__c = plibrary1.Id;
        pContList1[0].Main_Message__c = 'Main Message 1 - Desktop';
        pContList1[0].Placement_Layout__c = layout1.Id;
        pContList1[0].Page_Name__c =layout1.Page_Types__c; 
        pContList1[1].S_No__c = 1;
        pContList1[1].Placement_Library__c = plibrary1.Id;
        pContList1[1].Main_Message__c = 'Main Message 2 - Desktop';
        pContList1[1].Placement_Layout__c = layout2.Id;
        pContList1[1].Page_Name__c =layout2.Page_Types__c;
        pContList1[2].S_No__c = 1;
        pContList1[2].Placement_Library__c = plibrary1.Id;
        pContList1[2].Main_Message__c = 'Main Message 3 - Desktop';
        pContList1[2].Placement_Layout__c = layout3.Id;
        pContList1[2].Page_Name__c =layout3.Page_Types__c;
                                                                                               
        //add/remove                                                                                       
        pContList1[3].S_No__c = 1;
        pContList1[3].Placement_Library__c = plibrary3.Id;
        pContList1[3].Main_Message__c = 'Main Message 1 - Mobile';
        pContList1[3].Placement_Layout__c = layout1.Id;
        pContList1[3].Page_Name__c =layout1.Page_Types__c; 
        pContList1[4].S_No__c = 1;
        pContList1[4].Placement_Library__c = plibrary4.Id;
        pContList1[4].Main_Message__c = 'Main Message 2 - Mobile';
        pContList1[4].Placement_Layout__c = layout2.Id;
        pContList1[4].Page_Name__c =layout2.Page_Types__c;
        pContList1[5].S_No__c = 1;
        pContList1[5].Placement_Library__c = plibrary5.Id;
        pContList1[5].Main_Message__c = 'Main Message 3 - Mobile';
        pContList1[5].Placement_Layout__c = layout3.Id;
        pContList1[5].Page_Name__c =layout3.Page_Types__c;
                                                                                               
        //no change                                                                                       
        pContList1[6].S_No__c = 1;
        pContList1[6].Placement_Library__c = plibrary2.Id;
        pContList1[6].Main_Message__c = 'Main Message Same';
        pContList1[6].Placement_Layout__c = layout1.Id;
        pContList1[6].Page_Name__c =layout1.Page_Types__c; 
        pContList1[7].S_No__c = 1;
        pContList1[7].Placement_Library__c = plibrary2.Id;
        pContList1[7].Main_Message__c = 'Main Message Same';
        pContList1[7].Placement_Layout__c = layout2.Id;
        pContList1[7].Page_Name__c =layout2.Page_Types__c;
        pContList1[8].S_No__c = 1;
        pContList1[8].Placement_Library__c = plibrary2.Id;
        pContList1[8].Main_Message__c = 'Main Message Same';
        pContList1[8].Placement_Layout__c = layout3.Id;
        pContList1[8].Page_Name__c =layout3.Page_Types__c;
        
        
        //no change and one with detail (add all) if layout 2 comes in query
        pContList1[9].S_No__c = 1;
        pContList1[9].Placement_Library__c = plibrary6.Id;
        pContList1[9].Main_Message__c = 'Main Message Same';
        pContList1[9].Placement_Layout__c = layout1.Id;
        pContList1[9].Page_Name__c =layout1.Page_Types__c; 
        pContList1[10].S_No__c = 1;
        pContList1[10].Placement_Library__c = plibrary6.Id;
        pContList1[10].Main_Message__c = 'Main Message Same';
        pContList1[10].Placement_Layout__c = layout2.Id;
        pContList1[10].Page_Name__c =layout2.Page_Types__c;
        
        //no change and one with detail (add all) if layout 3 comes in query
        pContList1[11].S_No__c = 1;
        pContList1[11].Placement_Library__c = plibrary7.Id;
        pContList1[11].Main_Message__c = 'Main Message Same';
        pContList1[11].Placement_Layout__c = layout2.Id;
        pContList1[11].Page_Name__c =layout2.Page_Types__c; 
        pContList1[12].S_No__c = 1;
        pContList1[12].Placement_Library__c = plibrary7.Id;
        pContList1[12].Main_Message__c = 'Main Message Same';
        pContList1[12].Placement_Layout__c = layout3.Id;
        pContList1[12].Page_Name__c =layout3.Page_Types__c;
        
        insert pContList1;
        
        // create placement content details
        List<Placement_Content_Detail__c> plContentList = new List<Placement_Content_Detail__c>();
        
        Placement_Content_Detail__c pcD1 = DGTL_TestDataFactory.createPlacementContentDetail(pContList1[0].Id,plibrary1.Id,false,'Slide 1','Path1','copy1'); // No change
        pcD1.Link_Text__c = 'url1';
        pcD1.Sub_Type__c = 'Video';
        plContentList.add(pcD1);
        Placement_Content_Detail__c pcD11 = DGTL_TestDataFactory.createPlacementContentDetail(pContList1[0].Id,plibrary1.Id,false,'Slide 1','Path11','copy1'); //update
        pcD11.Link_Text__c = 'url1';
        pcD11.Sub_Type__c = 'Video';
        plContentList.add(pcD11);
        Placement_Content_Detail__c pcD12 = DGTL_TestDataFactory.createPlacementContentDetail(pContList1[0].Id,plibrary1.Id,false,'Slide 1','Path1','copy1'); // remove/add
        pcD12.Link_Text__c = 'url1';
        pcD12.Sub_Type__c = 'Video';
        plContentList.add(pcD12);
        
        
        Placement_Content_Detail__c pcD2 = DGTL_TestDataFactory.createPlacementContentDetail(pContList1[1].Id,plibrary2.Id,false,'Slide 1','Path1','copy1'); // No change
        pcD2.Link_Text__c = 'url1';
        pcD2.Sub_Type__c = 'Video';
        plContentList.add(pcD2);
        Placement_Content_Detail__c pcD21 = DGTL_TestDataFactory.createPlacementContentDetail(pContList1[1].Id,plibrary2.Id,false,'Slide 1','Path12','copy1'); //update
        pcD21.Link_Text__c = 'url1';
        pcD21.Sub_Type__c = 'Video';
        plContentList.add(pcD21);
        Placement_Content_Detail__c pcD22 = DGTL_TestDataFactory.createPlacementContentDetail(pContList1[1].Id,plibrary2.Id,false,'Slide 1','Path2','copy1'); // remove/add
        pcD22.Link_Text__c = 'url1';
        pcD22.Sub_Type__c = 'Image';
        plContentList.add(pcD22);
      
        
        Placement_Content_Detail__c pcD3 = DGTL_TestDataFactory.createPlacementContentDetail(pContList1[2].Id,plibrary1.Id,false,'Slide 1','Path1','copy1'); // No change
        pcD3.Link_Text__c = 'url1';
        pcD3.Sub_Type__c = 'Video';
        plContentList.add(pcD3);
        Placement_Content_Detail__c pcD31 = DGTL_TestDataFactory.createPlacementContentDetail(pContList1[2].Id,plibrary1.Id,false,'Slide 1','Path13','copy1'); //update
        pcD31.Link_Text__c = 'url1';
        pcD31.Sub_Type__c = 'Video';
        plContentList.add(pcD31);
        Placement_Content_Detail__c pcD32 = DGTL_TestDataFactory.createPlacementContentDetail(pContList1[2].Id,plibrary1.Id,false,'Slide 1','Path3','copy1'); // remove/add
        pcD32.Link_Text__c = 'url1';
        pcD32.Sub_Type__c = 'Dynamic';
        plContentList.add(pcD32);
        
        
        Placement_Content_Detail__c pcD4 = DGTL_TestDataFactory.createPlacementContentDetail(pContList1[6].Id,plibrary1.Id,false,'Slide 1','Path11','copy1'); //update
        pcD4.Link_Text__c = 'url1';
        pcD4.Sub_Type__c = 'Video';
        plContentList.add(pcD4);

        Placement_Content_Detail__c pcD5 = DGTL_TestDataFactory.createPlacementContentDetail(pContList1[7].Id,plibrary2.Id,false,'Slide 1','Path12','copy1'); //update
        pcD5.Link_Text__c = 'url1';
        pcD5.Sub_Type__c = 'Video';
        plContentList.add(pcD5);
        
        Placement_Content_Detail__c pcD6 = DGTL_TestDataFactory.createPlacementContentDetail(pContList1[8].Id,plibrary1.Id,false,'Slide 1','Path13','copy1'); //update
        pcD6.Link_Text__c = 'url1';
        pcD6.Sub_Type__c = 'Video';
        plContentList.add(pcD6);
        
        Placement_Content_Detail__c pcD7 = DGTL_TestDataFactory.createPlacementContentDetail(pContList1[10].Id,plibrary1.Id,false,'Slide 1','Path13','copy1');
        pcD6.Link_Text__c = 'url1';
        pcD6.Sub_Type__c = 'Video';
        plContentList.add(pcD7);
        
        Placement_Content_Detail__c pcD8 = DGTL_TestDataFactory.createPlacementContentDetail(pContList1[12].Id,plibrary1.Id,false,'Slide 1','Path13','copy1');
        pcD6.Link_Text__c = 'url1';
        pcD6.Sub_Type__c = 'Video';
        plContentList.add(pcD8);
                
        insert plContentList;
       
    }
    
    Public static testMethod void basicTestMethods(){
        Test.startTest();
        DGTL_Floorset_Plan__c flr = [SELECT Id,Name FROM DGTL_Floorset_Plan__c limit 1 ];
        Placement_Layout__c lay = [select id,Name from Placement_Layout__c limit 1];
        Placement_Content__c cont = [select id,Name,Placement_Layout__c from Placement_Content__c limit 1]; //where Placement_Layout__c = :lay.id
        DGTL_Util.getFloorsetName(string.valueOf(flr.id));
        DGTL_ComparePlcLayout_Ctr.getUserBrandHpr();
        DGTL_ComparePlcLayout_Ctr.getFields();
        DGTL_ComparePlcLayout_Ctr.getUserPreferenceSettings('VS');
        DGTL_ComparePlcLayout_Ctr.saveAcknowledgeRecord(string.valueOf(lay.Id));
        DGTL_ComparePlcLayout_Ctr.getHistory(string.valueOf(lay.Id),string.valueOf(cont.Id),'VS');
        DGTL_ComparePlcLayout_Ctr.getContentHasHistory(string.valueOf(lay.Id),'VS');
        DGTL_ComparePlcLayout_Ctr.pLayoutWpr wrpCls = new DGTL_ComparePlcLayout_Ctr.pLayoutWpr();
        DGTL_ComparePlcLayout_Ctr.saveUserPreference(DGTL_ComparePlcLayout_Ctr.getUserPreferenceSettings('VS'));
        DGTL_ComparePlcLayout_Ctr.fetchData('VS','Home Page', Date.today().addDays(-1), Date.today().addDays(1),'Desktop', '',DGTL_ComparePlcLayout_Ctr.getUserPreferenceSettings('VS'));
        Test.stopTest();
    }
    public static testMethod void setupValuesTest(){
        Test.startTest();
        DGTL_ComparePlcLayout_Ctr.setUpValues();
        Test.stopTest();
        
    }
    
    public static testMethod void fetchLayoutDataTest(){
        Id layoutId = [SELECT Id FROM Placement_Layout__c LIMIT 1].Id;
        Test.startTest();
        DGTL_ComparePlcLayout_Ctr.fetchLayoutData(layoutId);
        Test.stopTest();
    }
    
   /* public static testMethod void fetchDataTest(){
        Test.startTest();
        DGTL_ComparePlcLayout_Ctr.fetchData('VS','Home Page', Date.today().addDays(-1), Date.today().addDays(1),'Desktop', '','');
        Test.stopTest();
    }*/
    
    public static testMethod void getEditorialNamesTest(){
        DGTL_Floorset_Plan__c vsFloorsetPlan1 = DGTL_TestDataFactory.createFloorsetPlan('VS',DATE.today(),'3 AM','Update');
        insert vsFloorsetPlan1;
        
        Placement_Layout__c layout1 = DGTL_TestDataFactory.createPlacementLayout('VS','Home Page','Mobile',vsFloorsetPlan1.Id, 'Layout');
        layout1.Page_Types__c = 'Editorials';
        layout1.Collection_Page_Name__c = 'test';
        insert layout1;
        
        Test.startTest();
        DGTL_ComparePlcLayout_Ctr.getEditorialNames(false,'test','VS');
        Test.stopTest();
        DGTL_ComparePlcLayout_Ctr.getEditorialNames(true,'','VS');
    }

}