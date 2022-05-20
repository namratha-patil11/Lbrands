/************************************************************
Name          : DGTL_Notifications_SCHTest
Description   : Test Class for DGTL_Notifications_SCH
*************************************************************/
@isTest
public class DGTL_Notifications_SCHTest {
	       @TestSetup
    static void initialize(){
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
        insert list_contentDetail;
        
        list<DGTL_Access_Management__c> list_accessMgmt = new list<DGTL_Access_Management__c>();
        list_accessMgmt.add(DGTL_TestDataFactory.createAccessManagmentWithCategory('VS', 'Placement_Content__c','Image__c;Link__c;Main_Message__c;Offer_Type__c', 'Bras','DGTL_Merchandiser','My Test Group00'));
        list_accessMgmt.add(DGTL_TestDataFactory.createAccessManagmentWithCategory1('VS','Placement_Content__c','Image__c;Link__c;Main_Message__c;Offer_Type__c','Panties','DGTL_Copy_Writer','My Test Group00'));
        list_accessMgmt.add(DGTL_TestDataFactory.createAccessManagmentWithCategory1('VS','Placement_Content__c','Image__c;Link__c;Main_Message__c;Offer_Type__c','Panties','DGTL_Creative_Design','My Test Group00'));
        list_accessMgmt.add(DGTL_TestDataFactory.createAccessManagmentWithCategory('VS','Placement_Content__c','Image__c;Link__c;Main_Message__c;Offer_Type__c','Sleep','DGTL_Digital_Producers','My Test Group00'));
        list_accessMgmt.add(DGTL_TestDataFactory.createAccessManagmentWithCategory1('VS','Placement_Content__c','Image__c;Link__c;Main_Message__c;Offer_Type__c','Sleep','DGTL_Commerce_Operations','My Test Group00'));
        list_accessMgmt.add(DGTL_TestDataFactory.createAccessManagmentWithCategory('VS','Placement_Content__c','Image__c;Link__c;Main_Message__c;Offer_Type__c','Bras','DGTL_Bangalore_Commerce_Services','My Test Group00'));
        insert list_accessMgmt;
        
        list<History_Tracking__c> list_HistoryTracking = new list<History_Tracking__c>();
        list_HistoryTracking.add(DGTL_TestDataFactory.createOnChangeHisRec('VS','DGTL_Merchandiser','Bras',list_Content[0].id,testLayout.Id));
        list_HistoryTracking.add(DGTL_TestDataFactory.createOnChangeHisRec('VS','DGTL_Copy_Writer','Bras',list_Content[0].id,testLayout.Id));
        list_HistoryTracking.add(DGTL_TestDataFactory.createOnChangeHisRec('VS','DGTL_Creative_Design','Bras',list_Content[0].id,testLayout.Id)); 
        list_HistoryTracking.add(DGTL_TestDataFactory.createOnChangeHisRec('VS','DGTL_Digital_Producers','Bras',list_Content[0].id,testLayout.Id));
        list_HistoryTracking.add(DGTL_TestDataFactory.createOnChangeHisRec('VS','DGTL_Commerce_Operations','Bras',list_Content[0].id,testLayout.Id));
        History_Tracking__c newRec = DGTL_TestDataFactory.createOnChangeHisRec('VS','DGTL_Bangalore_Commerce_Services','Bras',list_Content[0].id,testLayout.Id);
        newRec.Object_Name__c = 'Placement Content Detail';        list_HistoryTracking.add(newRec);
        insert list_HistoryTracking;
        
    }
    
    static testmethod void testMethod1(){
        
        Profile objprofile = [select id from Profile where Name='DGTL Base Profile' LIMIT 1];
        user merUser = DGTL_TestDataFactory.createUser(objprofile.Id,'DGTL_Merchandiser');
        insert merUser;
        
        system.runAs(merUser){
            test.startTest();
            CollaborationGroup myGroup = new CollaborationGroup();
            myGroup.Name='My Test Group00';
            myGroup.CollaborationType='Public'; //can be 'Public' or 'Private'                   
            insert myGroup;
        
        /*
        CollaborationGroupMember groupMember = new CollaborationGroupMember();
        groupMember.memberid = merUser.Id; //id of User you wish to add
        groupMember.CollaborationGroupId = myGroup.Id; //Id of group created above
        insert groupMember; */
        
            DGTL_Notifications_SCH taskNotification= new DGTL_Notifications_SCH();
            String cronStr = '0 30 * * * ?';
            System.schedule('DGTL Daily Task DGTL_Notifications_SCH Test000000000', '0 0 * * * ?', taskNotification);
            test.stopTest();
        }
        
        
    }
}