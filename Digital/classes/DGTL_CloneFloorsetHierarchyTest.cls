/************************************************************
Name          : DGTL_CloneFloorsetHierarchyTest
Description   : Test Class for DGTL_CloneFloorsetHierarchy
*************************************************************/
@isTest
public class DGTL_CloneFloorsetHierarchyTest {
    
    
    static testmethod void testMethod1(){
        List<Placement_Layout__c> Layouts = new List<Placement_Layout__c>();
        
        DGTL_Floorset_Plan__c Floorset = DGTL_TestDataFactory.createFloorsetPlan('VS', Date.today(), '5 AM', 'Floorset');
        insert Floorset;
        
        DGTL_Floorset_Plan__c Floorset1 = DGTL_TestDataFactory.createFloorsetPlan('VS',  Date.today().addDays(-1), '5 AM', 'Floorset');
        insert Floorset1;
        
        Placement_Layout__c Layout = DGTL_TestDataFactory.createPlacementLayout('VS','Home Page','Desktop',Floorset.Id, 'Layout');
        insert Layout;
        
        Placement_Layout__c Layout1 = DGTL_TestDataFactory.createPlacementLayout('VS','Home Page','Desktop',Floorset1.Id, 'Layout');
        insert Layout1;
        
        Layouts.add(Layout);
        Layouts.add(Layout1);
        
        Test.startTest(); 
        DGTL_CloneFloorsetHierarchy.getPreviousFloorsetPlan(Floorset.Id);
        DGTL_CloneFloorsetHierarchy.cloneFloorsetChildHierarchy(Floorset.Id, Floorset1.Id, Layouts);
        Test.stopTest();
        
    }
    
}