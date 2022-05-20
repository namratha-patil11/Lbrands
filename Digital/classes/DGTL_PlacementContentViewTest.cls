/************************************************************
Name          : DGTL_PlacementContentViewTest
Description   : Test Class for DGTL_PlacementContentView  
*************************************************************/
@isTest
public class DGTL_PlacementContentViewTest {
    
    
    static testmethod void testMethod1(){
        Test.startTest();
        DGTL_Floorset_Plan__c testFloorset = DGTL_TestDataFactory.createFloorsetPlan('VS', Date.today(), '5 AM', 'Floorset');
        insert testFloorset;
        
        Placement_Layout__c testLayout = DGTL_TestDataFactory.createPlacementLayout('VS','Home Page','Desktop',testFloorset.Id, 'Layout');
        insert testLayout;
        
        list<Placement_Content__c> list_Content = DGTL_TestDataFactory.createPlacementContentlist(testLayout.Id,testLayout.Page_Types__c, 1,
                                                                                                  null,'Some Message','Video','Controlled','Feature','Offer');
        insert list_Content;
        DGTL_PlacementContentView.getLayoutId(list_Content[0].Id);
        Test.stopTest();
    }
            

}