/************************************************************
Name          : DGTL_Snapshot_SCHTest
Description   : Test Class for DGTL_DailyTaskNotification_SCH, DGTL_GenericMultiLevelClone
*************************************************************/
@isTest
public class DGTL_Snapshot_SCHTest {
    
    static testMethod void exe()
    {
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
        
        Test.StartTest();
        DGTL_Snapshot_SCH DGTL_Snapshot= new DGTL_Snapshot_SCH();
        System.schedule('DGTL Daily DGTL_SnapshotTestttttt000000', '0 0 * * * ?', DGTL_Snapshot);
        Test.StopTest();
    }
    
    
}