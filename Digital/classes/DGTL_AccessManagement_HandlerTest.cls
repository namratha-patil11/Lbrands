/************************************************************
Name          : DGTL_AccessManagement_HandlerTest
Description   : Test Class for DGTL_AccessManagementTrigger ,DGTL_AccessManagement_Handler,DGTL_AccessManagement_Services
*************************************************************/
@isTest
public class DGTL_AccessManagement_HandlerTest {
    static testmethod void  method1(){
        Id recordTypeId = Schema.SObjectType.DGTL_Access_Management__c.getRecordTypeInfosByName().get('Notification').getRecordTypeId();
        
        list<DGTL_Access_Management__c> list_AccessMng = new list<DGTL_Access_Management__c>();
        list_AccessMng.add(DGTL_TestDataFactory.createAccessManagment('VS','Placement_Content_Detail__c',
                                                                      'Asset_Path__c;Copy__c;Slides__c;Detail Added;Detail Deleted;',
                                                                      'Asset_Path__c;Copy__c;Slides__c;Detail Added;Detail Deleted;','','',
                                                                      recordTypeId,'DGTL_Merchandiser'));
        list_AccessMng[0].Schedule_Interval_Time__c = '30 mins';
        list_AccessMng[0].Last_Schedule_time__c = System.now();
        insert list_AccessMng;
        
        list_AccessMng[0].Schedule_Interval_Time__c = '60 mins';
        update list_AccessMng;
        
        delete list_AccessMng;
        
    }
    
}