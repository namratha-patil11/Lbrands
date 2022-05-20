/************************************************************
Name          : DGTL_TicketsServicesTest
Description   : Test Class for DGTL_TicketsServices,DGTL_TicketsTriggerHandler and DGTL_Tickets_Trigger
Author        : Vidya Sagar
Date          : 24 March 2020
*************************************************************/ 
@isTest
public class DGTL_TicketsServicesTest {
    
    @testSetup
    static void setupData(){
        list<DGTL_Floorset_Plan__c> list_Floorset = new list<DGTL_Floorset_Plan__c>();
        list_Floorset.add(DGTL_TestDataFactory.createFloorsetPlan('VS',date.today(),'5 AM','Update'));
        insert list_Floorset;
        list<Placement_Layout__c> list_layout = new list<Placement_Layout__c>();
        list_layout.add(DGTL_TestDataFactory.createPlacementLayout('VS','Home Page','Desktop',list_Floorset[0].Id, 'Layout'));
        insert list_layout;
        List<Placement_Content__c> list_Contents = DGTL_TestDataFactory.createPlacementContentlist(list_layout[0].Id,list_layout[0].Page_Types__c, 1,null,'Some Message','Video','Controlled','Feature','Non Offer');
        insert list_Contents;
        Id recordTypeId =   Schema.SObjectType.DGTL_Tickets__c.getRecordTypeInfosByDeveloperName().get('Data_Issues').getRecordTypeId();
        DGTL_Tickets__c objTicket = new DGTL_Tickets__c(Reason__c='Incorrect Copy',RecordTypeId=recordTypeId,Placement_Content__c=list_Contents[0].Id,Layout__c=list_layout[0].Id);
        insert objTicket;
    }
    
    public static testMethod void ticketTest(){
        Test.startTest();  
        DGTL_Tickets__c objtkt = [select id,Placement_Content__c from DGTL_Tickets__c limit 1];
        objtkt.Placement_Content__c = null;
        update objtkt;
        system.assertEquals(null, objtkt.Placement_Content__c);
        Test.stopTest();
    }
    }