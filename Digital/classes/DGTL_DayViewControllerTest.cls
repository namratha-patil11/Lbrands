@isTest
public class DGTL_DayViewControllerTest {
    
    @testSetup
    static void setupData(){
        Id recordTypeId = [SELECT Id FROM RecordType WHERE sObjectType='DGTL_Task__c' AND DeveloperName='Day_View'].Id;
       
        DGTL_Floorset_Plan__c vsFloorsetPlan1 = DGTL_TestDataFactory.createFloorsetPlan('VS',DATE.today(),'5 AM','Update');
        insert vsFloorsetPlan1;
                
        DGTL_Task__c task = new DGTL_Task__c(Desktop__c='Test',RecordTypeId=recordTypeId,Floorset_Plan__c=vsFloorsetPlan1.Id);
        insert task;
    }
    
    public static testMethod void getTaskId(){
        Id floorsetId = [SELECT Id FROM DGTL_Floorset_Plan__c LIMIT 1].Id;
        Test.startTest();
        DGTL_DayViewController.getTaskId(floorsetId);
        Test.stopTest();
        DGTL_Floorset_Plan__c vsFloorsetPlan2 = DGTL_TestDataFactory.createFloorsetPlan('VS',DATE.today(),'2 AM','Update');
        insert vsFloorsetPlan2;
        DGTL_DayViewController.getTaskId(vsFloorsetPlan2.Id);
    }

}