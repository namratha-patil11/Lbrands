/************************************************************
Name          : DGTL_PlacementContentUpdateTest
Description   : Test Class for DGTL_PlacementContentUpdate
*************************************************************/
@isTest
public class DGTL_PlacementContentUpdateTest {
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
        
        Placement_Content__c escalation = DGTL_TestDataFactory.createEscalationPlacementContent(testLayout.Id, null);
        escalation.Placement_Content_Self__c = list_Content[0].Id;
        insert escalation;
        
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
        
        list<Placement_Content_Detail__c> list_contentDetailEsc = new List<Placement_Content_Detail__c>();
        Placement_Content_Detail__c contentDetail01 = DGTL_TestDataFactory.createPlacementContentDetail(escalation.Id, null,
                                                                                                        false, 'Slide 1', 'asset path1', 'Copy text1');
        contentDetail01.Placement_Content_Detail_Self__c =list_contentDetail[0].Id; 
        
        Placement_Content_Detail__c contentDetail11 = DGTL_TestDataFactory.createPlacementContentDetail(escalation.Id, null,
                                                                                                        false, 'Slide 1', 'asset path1', 'Copy text1');
        contentDetail11.Placement_Content_Detail_Self__c =list_contentDetail[1].Id; 
        
        Placement_Content_Detail__c contentDetail12 = DGTL_TestDataFactory.createPlacementContentDetail(escalation.Id, null,
                                                                                                        false, 'Slide 1', 'asset path1', 'Copy text1');
        contentDetail12.Placement_Content_Detail_Self__c =list_contentDetail[2].Id; 
        contentDetail12.Is_Deleted__c = true;
        list_contentDetailEsc.add(contentDetail01);
        list_contentDetailEsc.add(contentDetail11);
        list_contentDetailEsc.add(contentDetail12);        
        insert list_contentDetailEsc;
        
        Id RecordTypeId = Schema.SObjectType.DGTL_Access_Management__c.getRecordTypeInfosByName().get('Field Access').getRecordTypeId();
        DGTL_Access_Management__c contentAccessRec = DGTL_TestDataFactory.createAccessManagment('VS','Placement_Content__c','Image__c;Link__c;','Image__c;Link__c;',
                                                                                                '','DGTL Main',RecordTypeId,'DGTL_Merchandiser');
        insert contentAccessRec;
        DGTL_Access_Management__c contentDetailAccessRec = DGTL_TestDataFactory.createAccessManagment('VS','Placement_Content_Detail__c','Copy__c;Slides__c;','Copy__c;Slides__c;',
                                                                                                      '','Layout - Content Detail',RecordTypeId,'DGTL_Merchandiser');
        insert contentDetailAccessRec;
        
        DGTL_Task__c digitalTask = DGTL_TestDataFactory.createEscalationTask(list_Content[0].Id);
        insert digitalTask;
    }
    
    static testmethod void testMethod1(){
        Profile objprofile = [select id from Profile where Name='DGTL Base Profile' LIMIT 1];
        user merUser = DGTL_TestDataFactory.createUser(objprofile.Id,'DGTL_Merchandiser');
        insert merUser;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'DGTL_Merchandiser'];
        PermissionSetAssignment psAssign = DGTL_TestDataFactory.createPermissionSetAssgn(merUser.Id,ps.Id);
        insert psAssign;
        Group grp = new Group();
        grp.name = 'VS-Escalation Queue';
        grp.Type = 'Regular'; 
        Insert grp; 
        //Create Group Member
        GroupMember grpMem1 = new GroupMember();
        grpMem1.UserOrGroupId = merUser.Id;
        grpMem1.GroupId = grp.Id;
        Insert grpMem1;
        System.runAs(merUser){ 
            Test.startTest(); 
            
            DGTL_PlacementContentUpdate.DGTL_UpdateWraper DGTL_ResWraper = New DGTL_PlacementContentUpdate.DGTL_UpdateWraper();        
            list<Placement_Content__c> list_Content = [SELECT ID,Image__c,name,Link__c,Placement_Content_Self__c,Brand__c,Placement_Page_Type__c,LastModifiedDate,
                                                       Has_Unapproved__c,Placement_Layout__c,Type__c,Placement_Library__c,LastModifiedBy.Name,
                                                       Main_Message__c,Offer_Type__c,Content_Type__c from Placement_Content__c where Type__c='Controlled'];
            
            Placement_Content__c escalationContent = [SELECT ID,Image__c,name,Link__c,Placement_Content_Self__c,Brand__c,Placement_Page_Type__c,LastModifiedDate,
                                                      Has_Unapproved__c,Type__c,Placement_Layout__c,Placement_Library__c,LastModifiedBy.Name,
                                                      Main_Message__c,Offer_Type__c,Content_Type__c from Placement_Content__c
                                                      where Type__c='Escalation'];
            list<Placement_Content_Detail__c> contentDetail = [SELECT ID,name,Link_Text__c,Placement_Content__c,Sub_Type__c,Asset_Path__c,LastModifiedDate,
                                                               Copy__c,Slides__c,Is_Deleted__c,Placement_Content_Detail_Self__c,LastModifiedBy.Name,Comments__c
                                                               from Placement_Content_Detail__c];
            list<Placement_Content_Detail__c> list_DetelePlacementContentDetail = new list<Placement_Content_Detail__c>();
            list<Placement_Content_Detail__c> list_DetelePlacementContentDetailOld = new list<Placement_Content_Detail__c>();
            
            list<String> contentFields = new list<String>();
            contentFields.add('Image__c');        contentFields.add('Link__c');
            
            map<String,String> map_DetailWriteFields = new  map<String,String>();
            map_DetailWriteFields.put('Copy__c','Copy__c');        map_DetailWriteFields.put('Slides__c','Slides__c');
            
            map<String,String> map_WriteFields = new  map<String,String>();
            map_WriteFields.put('Image__c','Image__c');        map_WriteFields.put('Link__c','Link__c');
            map_WriteFields.put('Main_Message__c','Main_Message__c');        map_WriteFields.put('Offer_Type__c','Offer_Type__c');
            
            DGTL_PlacementContentUpdate.initialize(list_Content[0].Id);
            
            list_Content[0].Main_Message__c = 'hgfiufbgquwebucfhbhqeiubcf';
            list_Content[0].Offer_Type__c ='Non Offer';
            // list_Content[0].Link__c ='73654jhbjwgdywg';
            DGTL_PlacementContentUpdate.saveChanges(contentDetail,list_DetelePlacementContentDetail,
                                                    list_DetelePlacementContentDetailOld, map_DetailWriteFields, map_WriteFields,
                                                    true, list_Content[0],contentFields);
            
            contentDetail[0].Copy__c = 'new Copy Text';        contentDetail[1].Slides__c ='Slide 2';
            Placement_Content_Detail__c contentDetailNew = DGTL_TestDataFactory.createPlacementContentDetail(list_Content[0].Id, null,
                                                                                                             false, 'Slide 1', 'asset path Text', 'Copy text');
            Placement_Content_Detail__c newDet  = new Placement_Content_Detail__c();
            newDet.Id = null;
            contentDetail.add(newDet);        contentDetail.add(contentDetailNew);
            
            DGTL_PlacementContentUpdate.saveChanges(contentDetail,list_DetelePlacementContentDetail,
                                                    list_DetelePlacementContentDetailOld, map_DetailWriteFields, map_WriteFields,
                                                    false, escalationContent,contentFields); 
            
            DGTL_Task__c taskaskObj = [SELECT ID,name,Brand__c,Changed_Content_Fields__c from  DGTL_Task__c  LIMIT 1];
            DGTL_PlacementContentUpdate.sendEscalationEmail(taskaskObj);
            
            Test.stopTest();
            
        }
    }
    
    static testmethod void testMethod2(){
        Test.startTest(); 
        DGTL_PlacementContentUpdate.DGTL_UpdateWraper DGTL_ResWraper = New DGTL_PlacementContentUpdate.DGTL_UpdateWraper();        
        Placement_Content__c escalationContent = [SELECT ID,Image__c,name,Link__c,Placement_Content_Self__c,Brand__c,Placement_Page_Type__c,LastModifiedDate,
                                                  Has_Unapproved__c,Type__c,Placement_Layout__c,Placement_Library__c,LastModifiedBy.Name,
                                                  Main_Message__c,Offer_Type__c,Content_Type__c from Placement_Content__c
                                                  where Type__c='Escalation'];
        list<Placement_Content_Detail__c> contentDetail = [SELECT ID,name,Link_Text__c,Placement_Content__c,Sub_Type__c,Asset_Path__c,LastModifiedDate,
                                                           Copy__c,Slides__c,Is_Deleted__c,LastModifiedBy.Name,Placement_Content_Detail_Self__c,Comments__c
                                                           from Placement_Content_Detail__c];
        list<Placement_Content_Detail__c> list_DetelePlacementContentDetail = new list<Placement_Content_Detail__c>();
        list<Placement_Content_Detail__c> list_DetelePlacementContentDetailOld = new list<Placement_Content_Detail__c>();
        
        DGTL_PlacementContentUpdate.initialize(escalationContent.Id);
        list<String> contentFields = new list<String>();        contentFields.add('Image__c');        contentFields.add('Link__c');
        
        map<String,String> map_DetailWriteFields = new  map<String,String>();
        map_DetailWriteFields.put('Copy__c','Copy__c');        map_DetailWriteFields.put('Slides__c','Slides__c');
        
        map<String,String> map_WriteFields = new  map<String,String>();
        map_WriteFields.put('Image__c','Image__c');        map_WriteFields.put('Link__c','Link__c');
        
        Placement_Content_Detail__c delDetail = DGTL_TestDataFactory.createPlacementContentDetail(escalationContent.Id, null,
                                                                                                  false, 'Slide 1', 'asset path Text', 'Copy text');
        Placement_Content_Detail__c delDetail1 = DGTL_TestDataFactory.createPlacementContentDetail(escalationContent.Id, null,
                                                                                                   false, 'Slide 1', 'asset path Text', 'Copy text');
        
        delDetail.Is_Deleted__c = false; upsert delDetail;        Placement_Content_Detail__c detNew = new Placement_Content_Detail__c();
        list_DetelePlacementContentDetail.add(delDetail);   list_DetelePlacementContentDetail.add(delDetail1);   
        list_DetelePlacementContentDetailOld.add(delDetail);
        contentDetail.add(detNew);
        
        contentDetail[0].Copy__c ='hefbhuygwefuyywe';
        escalationContent.Main_Message__c = 'jhbfhebfuewgbfuyy';
        DGTL_PlacementContentUpdate.saveChanges(contentDetail,list_DetelePlacementContentDetail,list_DetelePlacementContentDetailOld,
                                                map_DetailWriteFields, map_WriteFields,false, escalationContent,contentFields);
        
        DGTL_Task__c taskaskObj = [SELECT ID,name,Brand__c,Changed_Content_Fields__c from  DGTL_Task__c  LIMIT 1];
        DGTL_PlacementContentUpdate.sendEscalationEmail(taskaskObj);
        DGTL_PlacementContentUpdate.sendParentContentAndDetail(escalationContent);
        Test.stopTest();
    }
    
    static testmethod void testMethod3(){
        Test.startTest(); 
        list<Placement_Content__c> list_Content = [SELECT ID,Image__c,name,Link__c,Placement_Content_Self__c,Brand__c,Placement_Page_Type__c,LastModifiedDate,
                                                   Has_Unapproved__c,Placement_Layout__c,Type__c,Placement_Library__c,LastModifiedBy.Name,
                                                   Main_Message__c,Offer_Type__c,Content_Type__c from Placement_Content__c where Type__c='Controlled'];
        
        Placement_Content__c escalationContent = [SELECT ID,Image__c,name,Link__c,Placement_Content_Self__c,Brand__c,Placement_Page_Type__c,LastModifiedDate,
                                                  Has_Unapproved__c,Type__c,Placement_Layout__c,Placement_Library__c,LastModifiedBy.Name,
                                                  Main_Message__c,Offer_Type__c,Content_Type__c from Placement_Content__c
                                                  where Type__c='Escalation'];
        list<Placement_Content_Detail__c> contentDetail = [SELECT ID,name,Link_Text__c,Placement_Content__c,Sub_Type__c,Asset_Path__c,LastModifiedDate,
                                                           Copy__c,Slides__c,Is_Deleted__c,Placement_Content_Detail_Self__c,LastModifiedBy.Name,Comments__c
                                                           from Placement_Content_Detail__c];
        list<Placement_Content_Detail__c> list_DetelePlacementContentDetail = new list<Placement_Content_Detail__c>();
        list<Placement_Content_Detail__c> list_DetelePlacementContentDetailOld = new list<Placement_Content_Detail__c>();
        
        list<String> contentFields = new list<String>();
        contentFields.add('Image__c');        contentFields.add('Link__c');
        
        map<String,String> map_DetailWriteFields = new  map<String,String>();
        map_DetailWriteFields.put('Copy__c','Copy__c');        map_DetailWriteFields.put('Slides__c','Slides__c');
        
        map<String,String> map_WriteFields = new  map<String,String>();
        map_WriteFields.put('Image__c','Image__c');        map_WriteFields.put('Link__c','Link__c');
        
        DGTL_PlacementContentUpdate.initialize(list_Content[0].Id);
        
        //-----------------
        Placement_Content_Detail__c delDetail = DGTL_TestDataFactory.createPlacementContentDetail(escalationContent.Id, null,
                                                                                                  false, 'Slide 1', 'asset path Text', 'Copy text');
        Placement_Content_Detail__c delDetail1 = DGTL_TestDataFactory.createPlacementContentDetail(escalationContent.Id, null,
                                                                                                   false, 'Slide 1', 'asset path Text', 'Copy text');
        
        delDetail.Is_Deleted__c = false; upsert delDetail;        Placement_Content_Detail__c detNew = new Placement_Content_Detail__c();
        list_DetelePlacementContentDetail.add(delDetail);   list_DetelePlacementContentDetail.add(delDetail1); 
        //--------------------
        list_DetelePlacementContentDetailOld.add(delDetail);
        DGTL_PlacementContentUpdate.saveChanges(contentDetail,list_DetelePlacementContentDetail,
                                                list_DetelePlacementContentDetailOld, map_DetailWriteFields, map_WriteFields,
                                                true, list_Content[0],contentFields);
        
        contentDetail[0].Copy__c = 'new Copy Text';        contentDetail[1].Slides__c ='Slide 2';
        Placement_Content_Detail__c contentDetailNew = DGTL_TestDataFactory.createPlacementContentDetail(list_Content[0].Id, null,
                                                                                                         false, 'Slide 1', 'asset path Text', 'Copy text');
        Placement_Content_Detail__c newDet  = new Placement_Content_Detail__c();
        newDet.Id = null;
        contentDetail.add(newDet);        contentDetail.add(contentDetailNew);
        
        DGTL_PlacementContentUpdate.saveChanges(contentDetail,list_DetelePlacementContentDetail,
                                                list_DetelePlacementContentDetailOld, map_DetailWriteFields, map_WriteFields,
                                                false, escalationContent,contentFields); 
        
        DGTL_Task__c taskaskObj = [SELECT ID,name,Brand__c,Changed_Content_Fields__c from  DGTL_Task__c  LIMIT 1];
        DGTL_PlacementContentUpdate.sendEscalationEmail(taskaskObj);
        
        DGTL_PlacementContentUpdate.sendParentContentAndDetail(escalationContent);
        Test.stopTest();
    }
}