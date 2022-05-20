/************************************************************
Name          : DGT_cascadeContentCtrTest
Description   : Test Class for DGT_cascadeContentCtr
*************************************************************/
@isTest

public class DGT_cascadeContentCtrTest {
    
    
    @TestSetup
    static void datasetup(){
         DGTL_Floorset_Plan__c testFloorset = DGTL_TestDataFactory.createFloorsetPlan('VS', Date.today(), '5 AM', 'Floorset');
        insert testFloorset;
        DGTL_Floorset_Plan__c testFloorset1 = DGTL_TestDataFactory.createFloorsetPlan('VS', Date.today(), '11 AM', 'Update');
        insert testFloorset1;
        
        Placement_Layout__c testLayout = DGTL_TestDataFactory.createPlacementLayout('VS','Home Page','Desktop',testFloorset.Id, 'Layout');
        insert testLayout;
        
        Placement_Layout__c testLayout1 = DGTL_TestDataFactory.createPlacementLayout('VS','Home Page','Mobile',testFloorset.Id, 'Layout');
        insert testLayout1;
        Placement_Layout__c testLayout2 = DGTL_TestDataFactory.createPlacementLayout('VS','Bras LP','Desktop',testFloorset.Id, 'Layout');
        insert testLayout2;
        
        Placement_Library__c testLib = DGTL_TestDataFactory.createPlacementLibrary(DATE.today(), DATE.today()+1,
                                                                                   'VS', 'Home Page', '5 AM', '5 AM',
                                                                                   'Desktop', 'Approved', 'Non Offer', 'mainMsg');
        insert testLib;
        
        list<Placement_Content__c> list_Content = new  list<Placement_Content__c>();
        list_Content.add(DGTL_TestDataFactory.createPlacementContent(testLayout.Id, testLib.Id));
        list_Content.add(DGTL_TestDataFactory.createPlacementContent(testLayout1.Id, testLib.Id));
        list_Content.add(DGTL_TestDataFactory.createPlacementContent(testLayout2.Id, testLib.Id));
        
        insert list_Content;
        
        list<Placement_Content_Detail__c> list_contentDetail = new List<Placement_Content_Detail__c>();
        Placement_Content_Detail__c contentDetail = DGTL_TestDataFactory.createPlacementContentDetail(list_Content[0].Id, testLib.Id,
                                                                                                      false, 'Slide 1', 'asset path', 'Copy text');
        
        Placement_Content_Detail__c contentDetail1 = DGTL_TestDataFactory.createPlacementContentDetail(list_Content[1].Id, testLib.Id,
                                                                                                       false, 'Slide 1', 'asset path1', 'Copy text1');
        Placement_Content_Detail__c contentDetail2 = DGTL_TestDataFactory.createPlacementContentDetail(list_Content[2].Id, testLib.Id,
                                                                                                       false, 'Slide 1', 'asset path1', 'Copy text1');
        list_contentDetail.add(contentDetail);
        list_contentDetail.add(contentDetail1);
        list_contentDetail.add(contentDetail2);
        insert list_contentDetail;
        
        Id fieldAccessId = Schema.SObjectType.DGTL_Access_Management__c.getRecordTypeInfosByName().get('Field Access').getRecordTypeId();
        list<DGTL_Access_Management__c> list_AccessMng = new list<DGTL_Access_Management__c>();
        list_AccessMng.add(DGTL_TestDataFactory.createAccessManagment('VS','Placement_Content__c',
                                                                      'Image__c;Link__c;Main_Message__c;Offer_Type__c;Has_Unapproved__c',
                                                                      'Image__c;Link__c;Main_Message__c;Offer_Type__c;Has_Unapproved__c','',
                                                                      'DGTL Main',fieldAccessId,'DGTL_Merchandiser'));
        list_AccessMng.add(DGTL_TestDataFactory.createAccessManagment('VS','Placement_Content_Detail__c',
                                                                      'Asset_Path__c;Copy__c;Is_Deleted__c','Asset_Path__c;Copy__c;Is_Deleted__c','',
                                                                      'Layout - Content Details',fieldAccessId,'DGTL_Merchandiser'));
        list_AccessMng[0].Buttons__c = 'clone';
        insert list_AccessMng;
        
        
        
        list_contentDetail[0].Slides__c = 'Slide 2'; list_contentDetail[0].Asset_Path__c = 'Slide 2'; list_contentDetail[0].Is_Deleted__c = true;
        list_contentDetail[1].Slides__c = 'Slide 2'; list_contentDetail[1].Asset_Path__c = 'Slide 2'; 
        list_contentDetail[2].Slides__c = 'Slide 2'; list_contentDetail[2].Asset_Path__c = 'Slide 2';
        update list_contentDetail;
    }
    
    static testmethod void testMethod1(){
        test.startTest();
       
        
        Profile objprofile = [select id from Profile where Name='DGTL Base Profile'];
        user merUser = DGTL_TestDataFactory.createUser(objprofile.Id,'DGTL_Merchandiser');
        insert merUser;
        
        System.runAs(merUser){
            list<Placement_Content__c> list_Content = [SELECT Id,name,Brand__c,Image__c,
                                                       Link__c,Main_Message__c,Page_Name__c,
                                                       Offer_Type__c from  Placement_Content__c];
            list<Placement_Content_Detail__c> list_contentDetail = [SELECT id,name,Slides__c,Asset_Path__c,Copy__c From Placement_Content_Detail__c ];
            list<string> detailId = new list<string>();
            list<string> selContKod = new list<string>();
            detailId.add(list_contentDetail[0].id);
            DGT_cascadeContentCtr.mainReturnDataWpr mainWrapClass = DGT_cascadeContentCtr.fetchContents(list_Content[0].Id);
            DGT_cascadeContentCtr.saveContents(list_Content,list_contentDetail,detailId,true,selContKod,'');
            
            list<DGT_cascadeContentCtr.contentDetWpr> list_contentDetWpr = new list<DGT_cascadeContentCtr.contentDetWpr>();
            DGT_cascadeContentCtr.contentDetWpr detWrap = new DGT_cascadeContentCtr.contentDetWpr();
            DGT_cascadeContentCtr.fieldDataWpr fieldData = new DGT_cascadeContentCtr.fieldDataWpr();
            fieldData.fieldLabel='Copy';
            fieldData.fieldApi='Copy__c';
            list<DGT_cascadeContentCtr.fieldDataWpr> list_fieldData = new list<DGT_cascadeContentCtr.fieldDataWpr>();
            list_fieldData.add(fieldData);
            detWrap.list_PlcConDetFieldData = list_fieldData;
            list_contentDetWpr.add(detWrap);
            
            
            DGT_cascadeContentCtr.addNewPlConDet(list_Content[0].Id,list_contentDetWpr[0]);
            DGT_cascadeContentCtr.promotePlConDets(list_Content[0].Id,list_contentDetWpr);
            
        }
        
        test.stopTest();
        
    }
    static testmethod void deletacce(){
        list<DGTL_Access_Management__c> list_AccessMng = [select id from DGTL_Access_Management__c ];
        delete list_AccessMng;
    }
    static testmethod void testMethod2(){
        
        test.startTest();
       
        
        Profile objprofile = [select id from Profile where Name='DGTL Base Profile'];
        user merUser = DGTL_TestDataFactory.createUser(objprofile.Id,'DGTL_Merchandiser');
        insert merUser;
        
        System.runAs(merUser){
            list<Placement_Content__c> list_Content = [SELECT Id,name,Brand__c,Image__c,
                                                       Link__c,Main_Message__c,Page_Name__c,
                                                       Offer_Type__c from  Placement_Content__c];
            list<Placement_Content_Detail__c> list_contentDetail = [SELECT id,name,Slides__c,Asset_Path__c,Copy__c From Placement_Content_Detail__c ];
            list<string> detailId = new list<string>();
            list<string> selContKod = new list<string>();
            detailId.add(list_contentDetail[0].id);
            DGT_cascadeContentCtr.mainReturnDataWpr mainWrapClass = DGT_cascadeContentCtr.fetchContents(list_Content[0].Id);
            DGT_cascadeContentCtr.saveContents(list_Content,list_contentDetail,detailId,true,selContKod,'');
        }
        test.stopTest();
    } 
    
}