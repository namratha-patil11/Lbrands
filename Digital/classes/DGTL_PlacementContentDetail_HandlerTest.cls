/************************************************************
Name          : DGTL_PlacementContentDetail_HandlerTest
Description   : Test Class for DGTL_PlacementContentDetail_Handler ,DGTL_PlacementContentDetTrgServices,DGTL_PlacementContentDetail_Trigger
*************************************************************/
@isTest
public class DGTL_PlacementContentDetail_HandlerTest {
    
      @TestSetup
    static void testMethod1(){
        DGTL_Floorset_Plan__c testFloorset = DGTL_TestDataFactory.createFloorsetPlan('VS', Date.today(), '5 AM', 'Floorset');
        insert testFloorset;
        
        Placement_Layout__c testLayout = DGTL_TestDataFactory.createPlacementLayout('VS','Home Page','Desktop',testFloorset.Id, 'Layout');
        insert testLayout;
        
        Placement_Library__c testLib = DGTL_TestDataFactory.createPlacementLibrary(DATE.today(), DATE.today()+1,
                                                                                   'VS', 'Home Page', '5 AM', '5 AM',
                                                                                   'Desktop', 'Approved', 'Non Offer', 'mainMsg');
        insert testLib;
        
        list<Placement_Content__c> list_Content = new  list<Placement_Content__c>();
        list_Content.add(DGTL_TestDataFactory.createPlacementContent(testLayout.Id, testLib.Id));
        insert list_Content;
        
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
        
        Id fieldAccessId = Schema.SObjectType.DGTL_Access_Management__c.getRecordTypeInfosByName().get('Field Access').getRecordTypeId();
        id taskRecId =  Schema.SObjectType.DGTL_Access_Management__c.getRecordTypeInfosByName().get('Task Creation').getRecordTypeId();

        list<DGTL_Access_Management__c> list_AccessMng = new list<DGTL_Access_Management__c>();
        list_AccessMng.add(DGTL_TestDataFactory.createAccessManagment('VS','Placement_Content_Detail__c',
                                                                      'Asset_Path__c;Copy__c;Slides__c;Detail Added;Detail Deleted;',
                                                                      'Asset_Path__c;Copy__c;Slides__c;Detail Added;Detail Deleted;','','History Tracking',
                                                                       fieldAccessId,'DGTL_Merchandiser'));
        list_AccessMng.add(DGTL_TestDataFactory.createAccessManagment('VS','Placement_Content_Detail__c',
                                                                      'Asset_Path__c;Copy__c;Slides__c;Detail Added;Detail Deleted;',
                                                                      'Asset_Path__c;Copy__c;Slides__c;Detail Added;Detail Deleted;','','History Tracking',
                                                                       fieldAccessId,'DGTL_Copy_Writer'));
         list_AccessMng.add(DGTL_TestDataFactory.createAccessManagment('VS','Placement_Content_Detail__c',
                                                                      'Asset_Path__c;Copy__c;Slides__c;Detail Added;Detail Deleted;',
                                                                      'Asset_Path__c;Copy__c;Slides__c;Detail Added;Detail Deleted;','','',
                                                                       taskRecId,'DGTL_Merchandiser'));
        list_AccessMng.add(DGTL_TestDataFactory.createAccessManagment('VS','Placement_Content_Detail__c',
                                                                      'Asset_Path__c;Copy__c;Slides__c;Detail Added;Detail Deleted;',
                                                                      'Asset_Path__c;Copy__c;Slides__c;Detail Added;Detail Deleted;','','',
                                                                       taskRecId,'DGTL_Copy_Writer'));
        
        list_AccessMng.add(DGTL_TestDataFactory.createAccessManagmentWithCategory('VS','Placement_Content_Detail__c',
                                                                      'Asset_Path__c;Copy__c;Slides__c;Detail Added;Detail Deleted;',
                                                                                  'Home Page', 'DGTL_Merchandiser','My Test Group00'));
        list_AccessMng.add(DGTL_TestDataFactory.createAccessManagmentWithCategory('VS','Placement_Content_Detail__c',
                                                                      'Asset_Path__c;Copy__c;Slides__c;Detail Added;Detail Deleted;',
                                                                                  'Home Page', 'DGTL_Copy_Writer','My Test Group00'));
        insert list_AccessMng; 
        
        insert list_contentDetail;
        
        list_contentDetail[0].Slides__c = 'Slide 2'; list_contentDetail[0].Asset_Path__c = 'Slide 2';
        list_contentDetail[1].Slides__c = 'Slide 2'; list_contentDetail[1].Asset_Path__c = 'Slide 2'; 
        list_contentDetail[2].Slides__c = 'Slide 2'; list_contentDetail[2].Asset_Path__c = 'Slide 2';
        update list_contentDetail;
        delete  list_contentDetail[2];
        
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