@isTest
public class DGTL_MultiContentDeleteTest {
    
    static testmethod void testMethod1(){
        Test.startTest();       
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
      
        list_contentDetail.add(contentDetail);
        list_contentDetail.add(contentDetail1);
        insert list_contentDetail;
        
        DGTL_MultiContentDelete.getRelatedPlacements(list_Content[0]);
        DGTL_MultiContentDelete.deletePlacements(list_Content);
        Test.stopTest();
    }
    
}