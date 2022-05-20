/************************************************************
Name          : DGTL_PlacementContent_HandlerTest
Description   : Test Class for DGTL_PlacementContent_Handler,DGTL_PlacementContentServices,
                DGTL_PlacementContentTrgHandler,DGTL_PlacementContent_Trigger
*************************************************************/
@isTest

public class DGTL_PlacementContent_HandlerTest {
  @TestSetup
    static void testMethod1(){
        test.startTest();
        Id fieldAccessId = Schema.SObjectType.DGTL_Access_Management__c.getRecordTypeInfosByName().get('Field Access').getRecordTypeId();
        id taskRecId =  Schema.SObjectType.DGTL_Access_Management__c.getRecordTypeInfosByName().get('Task Creation').getRecordTypeId();
        id notificationId =  Schema.SObjectType.DGTL_Access_Management__c.getRecordTypeInfosByName().get('Notification').getRecordTypeId();

        list<DGTL_Access_Management__c> list_AccessMng = new list<DGTL_Access_Management__c>();
        list_AccessMng.add(DGTL_TestDataFactory.createAccessManagment('VS','Placement_Content__c',
                                                                      'Image__c;Link__c;Main_Message__c;Offer_Type__c;Placement Added',
                                                                      'Image__c;Link__c;Main_Message__c;Offer_Type__c','','History Tracking',
                                                                       fieldAccessId,'DGTL_Merchandiser'));
        list_AccessMng.add(DGTL_TestDataFactory.createAccessManagment('VS','Placement_Content__c',
                                                                      'Image__c;Link__c;Main_Message__c;Offer_Type__c;Placement Added',
                                                                      'Image__c;Link__c;Main_Message__c;Offer_Type__c','','History Tracking',
                                                                       fieldAccessId,'DGTL_Copy_Writer'));
         list_AccessMng.add(DGTL_TestDataFactory.createAccessManagment('VS','Placement_Content__c',
                                                                      'Image__c;Link__c;Main_Message__c;Offer_Type__c;Placement Added',
                                                                      'Image__c;Link__c;Main_Message__c;Offer_Type__c','','',
                                                                       taskRecId,'DGTL_Merchandiser'));
        list_AccessMng.add(DGTL_TestDataFactory.createAccessManagment('VS','Placement_Content__c',
                                                                      'Image__c;Link__c;Main_Message__c;Offer_Type__c;Placement Added',
                                                                      'Image__c;Link__c;Main_Message__c;Offer_Type__c','','',
                                                                       taskRecId,'DGTL_Copy_Writer'));
        list_AccessMng.add(DGTL_TestDataFactory.createAccessManagmentWithCategory('VS','Placement_Content__c',
                                                                                  'Image__c;Link__c;Main_Message__c;Offer_Type__c;Placement Added;Active__c',
                                                                                  'Home Page', 'DGTL_Merchandiser','My Test Group00'));
        list_AccessMng.add(DGTL_TestDataFactory.createAccessManagmentWithCategory('VS','Placement_Content__c',
                                                                                  'Image__c;Link__c;Main_Message__c;Offer_Type__c;Placement Added;Active__c',
                                                                                  'Home Page', 'DGTL_Copy_Writer','My Test Group00'));
        insert list_AccessMng; 
        
        DGTL_Floorset_Plan__c testFloorset = DGTL_TestDataFactory.createFloorsetPlan('VS', Date.today(), '5 AM', 'Floorset');
        insert testFloorset;
        
        Placement_Layout__c testLayout = DGTL_TestDataFactory.createPlacementLayout('VS','Home Page','Desktop',testFloorset.Id, 'Layout');
        insert testLayout;
        
        Placement_Library__c testLib = DGTL_TestDataFactory.createPlacementLibrary(DATE.today(), DATE.today()+1,
                                                                                   'VS', 'Home Page', '5 AM', '5 AM',
                                                                                   'Desktop', 'Approved', 'Non Offer', 'mainMsg');
        insert testLib;
        
        Placement_Library__c testLib1 = DGTL_TestDataFactory.createPlacementLibrary(DATE.today()+2, DATE.today()+2,
                                                                                   'VS', 'Home Page', '5 AM', '5 AM',
                                                                                   'Mobile', 'Approved', 'Non Offer', 'mainMsg');
        insert testLib1;
        
        list<Placement_Content__c> list_Content = new  list<Placement_Content__c>();
        list_Content.add(DGTL_TestDataFactory.createPlacementContent(testLayout.Id, testLib.Id));
        list_Content.add(DGTL_TestDataFactory.createPlacementContent(testLayout.Id, testLib1.Id));
        insert list_Content;
        
        list<History_Tracking__c> list_HistoryRecords = new list<History_Tracking__c>();
        list_HistoryRecords.add(DGTL_TestDataFactory.createOnChangeHisRec('VS','DGTL_Merchandiser','',list_Content[0].id,testLayout.Id));
        insert list_HistoryRecords;
        
        
        
        list<Placement_Content_Detail__c> list_contentDetail = new List<Placement_Content_Detail__c>();
        Placement_Content_Detail__c contentDetail = DGTL_TestDataFactory.createPlacementContentDetail(list_Content[0].Id, null,
                                                                                                      false, 'Slide 1', 'asset path', 'Copy text');
        
        Placement_Content_Detail__c contentDetail1 = DGTL_TestDataFactory.createPlacementContentDetail(list_Content[0].Id, null,
                                                                                                       false, 'Slide 1', 'asset path1', 'Copy text1');
        Placement_Content_Detail__c contentDetail2 = DGTL_TestDataFactory.createPlacementContentDetail(list_Content[0].Id, null,
                                                                                                       false, 'Slide 1', 'asset path1', 'Copy text1');
        list_contentDetail.add(contentDetail);
        list_contentDetail.add(contentDetail1);
        list_contentDetail.add(contentDetail2);
        
        insert list_contentDetail;
        
        list_Content[0].Main_Message__c = 'ehcfuiygungyifeyghiueww';
        list_Content[0].Active__c = true;
        update list_Content;
        
        list_Content[0].Active__c = false;
        update list_Content;
        
        delete list_Content;
        
        test.stopTest();
        
    }
    
     static testmethod void testMethod2(){
        
        Profile objprofile = [select id from Profile where Name='DGTL Base Profile' LIMIT 1];
        user merUser = DGTL_TestDataFactory.createUser(objprofile.Id,'DGTL_Merchandiser');
        insert merUser;
        
        system.runAs(merUser){
            test.startTest();
            CollaborationGroup myGroup = new CollaborationGroup();
            myGroup.Name='My Test Group00';
            myGroup.CollaborationType='Public'; //can be 'Public' or 'Private'                   
            insert myGroup;
            test.stopTest();
            
        }
    }
    
}