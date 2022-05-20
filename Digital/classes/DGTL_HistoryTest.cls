/************************************************************
Name          : DGTL_HistoryTest
Description   : Test Class for DGTL_History      
*************************************************************/
@isTest
public class DGTL_HistoryTest {
    @TestSetup
        static void datasetup(){
         Test.startTest();
         list<DGTL_Floorset_Plan__c> list_Floorset = new list<DGTL_Floorset_Plan__c>();
            list_Floorset.add(DGTL_TestDataFactory.createFloorsetPlan('VS',date.today(),'5 AM','Update'));
            list_Floorset.add(DGTL_TestDataFactory.createFloorsetPlan('VS',date.today()+4,'5 AM','Update'));
            list_Floorset[0].Minute__c = null;
            list_Floorset[1].Minute__c = '10';
            insert  list_Floorset;
            list<Placement_Library__c> list_library = new list<Placement_Library__c>();
            list_library.add(DGTL_TestDataFactory.createPlacementLibrary(DATE.today(), DATE.today()+1, 'VS', 'Home Page', '5 AM', '5 AM', 'Desktop', 'Approved', 'Non Offer', 'mainMsg'));
            list_library.add(DGTL_TestDataFactory.createPlacementLibrary(DATE.today(), DATE.today()+2, 'VS', 'Home Page', '5 AM', '9 AM', 'Desktop', 'Approved', 'Non Offer', 'mainMsg2')); 
            list_library.add(DGTL_TestDataFactory.createPlacementLibrary(DATE.today(), DATE.today()+1, 'VS', 'Editorials', '5 AM', '5 AM', 'Desktop', 'Approved', 'Non Offer', 'mainMsg3'));
            list_library[0].Start_Minute__c = null;
            list_library[0].End_Minute__c = null;
            list_library[0].Placement_type__c = 'cue';
            list_library[0].Collection_Page_Url__c = 'collection page url test';
            list_library[2].Editorial_Name__c = 'Edt name History';
            list_library[2].Placement_type__c = 'cue';
            insert list_library;
            insert DGTL_TestDataFactory.createPlacementContentDetail(null,string.valueOf(list_library[0].Id),false,'Slide 1','assetPath','copy');
            list<Placement_Layout__c> list_layout = new list<Placement_Layout__c>();
            list_layout.add(DGTL_TestDataFactory.createPlacementLayout('VS','Home Page','Desktop',list_Floorset[1].Id, 'Layout'));
            list_layout.add(DGTL_TestDataFactory.createPlacementLayout('VS','Sport LP','Desktop',list_Floorset[1].Id, 'Layout'));
            list_layout.add(DGTL_TestDataFactory.createPlacementLayout('VS','Editorials','Desktop',list_Floorset[1].Id, 'Layout'));
            list_layout[2].Collection_Page_Name__c = 'Editorial Page test';
            insert list_layout;
            List<Placement_Content__c> list_Contents = DGTL_TestDataFactory.createPlacementContentlist(list_layout[0].Id,list_layout[0].Page_Types__c, 1,null,'Some Message','Video','Controlled','Feature','Non Offer');      
            list_Contents[0].Content_Type__c = 'Carousel';
            insert list_Contents;
            list<History_Tracking__c> lst_History = new list<History_Tracking__c>();
            Id historyRecTypeId = Schema.SObjectType.History_Tracking__c.getRecordTypeInfosByName().get('History Records').getRecordTypeId();
            History_Tracking__c contHist = new History_Tracking__c(Placement_Content__c = list_Contents[0].Id,RecordTypeId=historyRecTypeId,Field_API__c='Image__c',Old_Value__c='oldvalue',Object_Name__c='Placement Content',New_Value__c='newvalue');
            Id contDetailId = [select id from Placement_Content_Detail__c limit 1].Id;
            History_Tracking__c contDetHist = new History_Tracking__c(Placement_Content_Detail__c = contDetailId,RecordTypeId=historyRecTypeId,Field_API__c='Copy__c',Old_Value__c='oldvalue',Object_Name__c='Placement Content Detail',New_Value__c='newvalue');
            lst_History.add(contHist);
            lst_History.add(contDetHist);
            insert lst_History;
         Test.stopTest();
        }

        static testmethod void fetchHisTest(){
        Test.startTest();
        Id ContId = [select id from Placement_Content__c limit 1].Id;
        Id ContDetId = [select id from Placement_Content_Detail__c limit 1].Id;
        list<string> contEdtFields = new list<String>();
        contEdtFields.add('Image__c');
        list<string> contDtEdtFields = new list<String>();
        contDtEdtFields.add('Copy__c');
        system.assertEquals(DGTL_History.HistoryRecordsList(ContId,contEdtFields,contDtEdtFields).size(),1);
        system.assertEquals(DGTL_History.HistoryRecordsList(ContDetId,contEdtFields,contDtEdtFields).size(),1);
        system.assertEquals(DGTL_History.HistoryRecordsList(null,contEdtFields,contDtEdtFields),null);        
        Test.stopTest();
        }
}