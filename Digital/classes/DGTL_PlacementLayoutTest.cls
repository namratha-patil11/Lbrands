@isTest
public class DGTL_PlacementLayoutTest {
    
    public static testMethod void testupdateFloorsetCalendar(){
        
        
        DGTL_Floorset_Plan__c testFloorset = DGTL_TestDataFactory.createFloorsetPlan('VS', Date.today(), '5 AM', 'Floorset');
        insert testFloorset;
        
        Placement_Layout__c testLayout = DGTL_TestDataFactory.createPlacementLayout('VS','Home Page','Desktop',testFloorset.Id, 'Layout');
        insert testLayout;
        
        delete testLayout;
        DGTL_Floorset_Plan__c testFloorset2 = [select id, layouts__c from DGTL_Floorset_Plan__c where id =: testFloorset.id];
        system.assertEquals(null, testFloorset2.layouts__c);
        
    }
    
}