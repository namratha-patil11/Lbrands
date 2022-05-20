/************************************************************
Name          : DGTL_HistoryTrackingTest
Description   : Test Class for DGTL_HistoryTracking      
*************************************************************/
@isTest
public class DGTL_HistoryTrackingTest {

     @TestSetup
    static void initialize(){
        
        DGTL_Floorset_Plan__c testFloorset = DGTL_TestDataFactory.createFloorsetPlan('VS', Date.today(), '5 AM', 'Floorset');
        insert testFloorset;
        
        Placement_Layout__c testLayout = DGTL_TestDataFactory.createPlacementLayout('VS','Home Page','Desktop',testFloorset.Id, 'Layout');
        insert testLayout;
        
        list<Placement_Content__c> list_Content = DGTL_TestDataFactory.createPlacementContentlist(testLayout.Id,testLayout.Page_Types__c, 1,
                                                                                                 null,'Some Message','Video','Controlled','Feature','Offer');
        insert list_Content;
        
        Placement_Content_Detail__c contentDetail = DGTL_TestDataFactory.createPlacementContentDetail(list_Content[0].Id, null,
                                                                                                    false, 'Slide 1', 'asset path', 'Copy text');
        insert contentDetail;
        
        List<Placement_Content_Detail_History__c> List_DetHist = New List<Placement_Content_Detail_History__c>();
        Placement_Content_Detail_History__c Detailhist = DGTL_TestDataFactory.createContentDetailHistory(contentDetail.Id);
        Detailhist.Slides_Change__c = true;
        Detailhist.Copy_Change__c = true;
        Placement_Content_Detail_History__c Detailhist1 = DGTL_TestDataFactory.createContentDetailHistory(contentDetail.Id);
        Placement_Content_Detail_History__c Detailhist2 = DGTL_TestDataFactory.createContentDetailHistory(contentDetail.Id);
        List_DetHist.add(Detailhist);
        List_DetHist.add(Detailhist1);
        List_DetHist.add(Detailhist2);
        insert List_DetHist;
        
        List<Placement_Content_History__c> List_ContHist = New List<Placement_Content_History__c>();
        Placement_Content_History__c Conthist = DGTL_TestDataFactory.createContentHistory(list_Content[0].Id);
        Conthist.Image_Change__c = true;
        Conthist.Link_Change__c = true;
        Placement_Content_History__c Conthist1 = DGTL_TestDataFactory.createContentHistory(list_Content[0].Id);
        Placement_Content_History__c Conthist2 = DGTL_TestDataFactory.createContentHistory(list_Content[0].Id);
        List_ContHist.add(Conthist);
        List_ContHist.add(Conthist1);
        List_ContHist.add(Conthist2);
        insert List_ContHist;
        
        
        Id RecordTypeId = Schema.SObjectType.DGTL_Access_Management__c.getRecordTypeInfosByName().get('Field Access').getRecordTypeId();
        DGTL_Access_Management__c contentAccessRec = DGTL_TestDataFactory.createAccessManagment('VS','Placement_Content__c','','Image__c;Link__c;',
                                                                                                '','History Tracking',RecordTypeId,'DGTL_Merchandiser');
        insert contentAccessRec;
        DGTL_Access_Management__c contentDetailAccessRec = DGTL_TestDataFactory.createAccessManagment('VS','Placement_Content_Detail__c',
                                                                                                '','Copy__c;Slides__c;','','History Tracking',
                                                                                                RecordTypeId,'DGTL_Merchandiser');
        insert contentDetailAccessRec;
        
      
    }
    
    static testmethod void testMethod1(){
        Test.startTest(); 
        //DGTL_HistoryTracking DGTL_Cls = new DGTL_HistoryTracking();
        list<Placement_Content__c> list_Content = [SELECT ID,name from Placement_Content__c];
        Placement_Content_Detail__c contentDetail = [SELECT ID,name from Placement_Content_Detail__c LIMIT 1];
        DGTL_HistoryTracking.getHistoryRecords(list_Content[0].Id);
        DGTL_HistoryTracking.getHistoryRecords(contentDetail.Id);
        Test.stopTest();
    }
}