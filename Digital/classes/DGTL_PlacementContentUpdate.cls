public class DGTL_PlacementContentUpdate {
    
    @AuraEnabled
    public static DGTL_UpdateWraper initialize(String parentContentId){
        system.debug('parentContentId...'+parentContentId);
        DGTL_UpdateWraper DGTL_ResWraper = New DGTL_UpdateWraper();
        DGTL_UpdateWraper DGTL_ResWraperTemp = New DGTL_UpdateWraper();
        
        // Get record Brand , pageType and other Details from the Placement_Content__c
        Placement_Content__c plcContent = new Placement_Content__c();
        String contentQuery = DGTL_DataAccessor.getSobjectSoql(plcContent);
        contentQuery += ' AND Id =:parentContentId';
        system.debug('contentQuery...'+contentQuery);
        list<Placement_Content__c> list_plcContent = Database.query(contentQuery);
        if(list_plcContent.size() > 0) plcContent = list_plcContent[0];
        
        // Access management recordTypeId for For - Field Access
        Id recordTypeId = Schema.SObjectType.DGTL_Access_Management__c.getRecordTypeInfosByName().get('Field Access').getRecordTypeId();
        
        // Access management record for Placement_Content__c
        DGTL_Access_Management__c accessRecordPC = DGTL_DataAccessor.getAccessMang(plcContent.Brand__c,plcContent.Placement_Page_Type__c,
                                                                                   'Placement_Content__c', 'DGTL Main', recordTypeId);
        // get read and Write Fields
        if(accessRecordPC != null){
            // get read fields to be displayed 
            if(string.IsNotBlank(accessRecordPC.Read_Only_Fields__c)){
                system.debug('accessRecordPC.Read_Only_Fields__c.split'+accessRecordPC.Read_Only_Fields__c.split(';'));
                DGTL_ResWraper.map_ReadFields = DGTL_DataAccessor.getFieldLabels('Placement_Content__c', accessRecordPC.Read_Only_Fields__c.split(';'));
            }
            // get edit fields to be displayed 
            if(string.IsNotBlank(accessRecordPC.Writable_Fields__c)){
                system.debug('accessRecordPC.Read_Only_Fields__c.split'+accessRecordPC.Writable_Fields__c.split(';'));
                DGTL_ResWraper.map_WriteFields = DGTL_DataAccessor.getFieldLabels('Placement_Content__c', accessRecordPC.Writable_Fields__c.split(';'));
            }          
        }
        
        // Access management record for Placement_Content_Detail__c
        DGTL_Access_Management__c accessRecordPCD = DGTL_DataAccessor.getAccessMang(plcContent.Brand__c,null, 'Placement_Content_Detail__c',
                                                                                    'Layout - Content Details', recordTypeId);
        // get read and Write Fields
        if(accessRecordPCD != null){
            // get read fields to be displayed 
            if(string.IsNotBlank(accessRecordPCD.Read_Only_Fields__c)){
                DGTL_ResWraper.map_DetailReadFields = DGTL_DataAccessor.getFieldLabels('Placement_Content_Detail__c', accessRecordPCD.Read_Only_Fields__c.split(';'));
            }
            // get edit fields to be displayed 
            if(string.IsNotBlank(accessRecordPCD.Writable_Fields__c)){
                DGTL_ResWraper.map_DetailWriteFields = DGTL_DataAccessor.getFieldLabels('Placement_Content_Detail__c', accessRecordPCD.Writable_Fields__c.split(';'));
            }          
        }
        
        // Check if there is any record with the updated Changes 
        //(Update Records will have Lookup tp their parent/Original Records and Placement Layout Field Will be Blank)
        Placement_Content__c updatedVersion = new Placement_Content__c();
        
        set<ID> updatedId = New set<ID>();
        String updatedVersionID = '';
        
        Id TaskRecordTypeId = Schema.SObjectType.DGTL_Task__c.getRecordTypeInfosByName().get('Escalation').getRecordTypeId(); 
        List<DGTL_Task__c>  list_Task = [SELECT Id, Name , Status__c ,Placement_Content__c FROM DGTL_Task__c WHERE RecordTypeId =: TaskRecordTypeId
                                         AND Parent_Content__c =: parentContentId  AND Status__c = 'New'];
        system.debug('parentContentId....'+parentContentId);
        system.debug('list_Task....'+list_Task);
        if(list_Task.size()> 0 && list_Task[0].Placement_Content__c != null) {
            String escalationStr = 'Escalation';
            String updatedContentQuery = DGTL_DataAccessor.getSobjectSoql(plcContent);
            updatedContentQuery += ' AND id = \''+String.escapeSingleQuotes(list_Task[0].Placement_Content__c)+'\' AND Type__c =:escalationStr ';
            //updatedContentQuery = updatedContentQuery.substringBefore(')') + ' AND Is_Deleted__c = false )' + updatedContentQuery.substringAfter(')');
            
            list<Placement_Content__c> list_plcContentNew = Database.query(updatedContentQuery);    system.debug(list_plcContentNew);        
            if(list_plcContentNew.size() > 0 ) {
                DGTL_ResWraperTemp = sendParentContentAndDetail(list_plcContentNew[0]);
                DGTL_ResWraper.parentRecord = false;
            }
        }else{ 
            DGTL_ResWraperTemp = sendParentContentAndDetail(plcContent);
            DGTL_ResWraper.parentRecord = true;
        }
        
        if(list_Task.size() > 0)  DGTL_ResWraper.activeTaskRec = list_Task[0];
        DGTL_ResWraper.PlacementContent = DGTL_ResWraperTemp.PlacementContent;
        DGTL_ResWraper.hideSubType = DGTL_ResWraperTemp.hideSubType;
        DGTL_ResWraper.list_PlacementContentDetail = DGTL_ResWraperTemp.list_PlacementContentDetail;
        DGTL_ResWraper.list_DetelePlacementContentDetailOld = DGTL_ResWraperTemp.list_DetelePlacementContentDetailOld;
        system.debug('DGTL_ResWraperTemp.list_PlacementContentDetail...'+DGTL_ResWraperTemp.list_PlacementContentDetail);
        
        return DGTL_ResWraper;
    }
    
    @AuraEnabled
    Public Static Boolean saveChanges(List<Placement_Content_Detail__c> list_PlacementContentDetail,
                                      List<Placement_Content_Detail__c> list_DetelePlacementContentDetail,
                                      List<Placement_Content_Detail__c> list_DetelePlacementContentDetailOld,
                                      map<String,String> map_DetailWriteFields, map<String,String> map_WriteFields,
                                      Boolean parentRecord, Placement_Content__c PlacementContent, List<String> contentFields)
    {
        system.debug('PlacementContent...'+PlacementContent);
        system.debug('parentRecord...'+parentRecord);
        system.debug('list_DetelePlacementContentDetail....'+list_DetelePlacementContentDetail);
        system.debug('list_PlacementContentDetail....'+list_PlacementContentDetail);
        Boolean Changed = false;
        Boolean ContentDetailChanged = false;
        Boolean ContentChanged = false;
        Placement_Content__c contentRecord = New Placement_Content__c();
        List<Placement_Content_Detail__c> list_PlacementContentDetailOld = New List<Placement_Content_Detail__c>();
        List<Placement_Content_Detail__c> list_PlacementContentDetailNew = New List<Placement_Content_Detail__c>();
        List<Placement_Content_Detail__c> list_PlacementContentDetailCloned = New List<Placement_Content_Detail__c>();
        List<Placement_Content_Detail__c> list_AddedPlacementContentDetail  = New List<Placement_Content_Detail__c>(); 
        List<Placement_Content_Detail__c> list_OriginalPlacementContentDetailDelete  = New List<Placement_Content_Detail__c>(); 
        String changedPCdFields = '';
        String changedPlcContFields = '';
        map<Id,String> map_PCDChangedFields = New map<Id,String>();
        map<Id,Placement_Content_Detail__c> oldMap_PlcContDetail = new map<Id,Placement_Content_Detail__c>();
        map<Id,Placement_Content_Detail__c> newMap_PlcContDetail = new map<Id,Placement_Content_Detail__c>();
        map<Id,Placement_Content__c> oldMap_PlcCont = new map<Id,Placement_Content__c>();
        map<Id,Placement_Content__c> newMap_PlcCont = new map<Id,Placement_Content__c>();
        
        // get lists from the Changed Content
        list_PlacementContentDetailNew = list_PlacementContentDetail;
        
        if(parentRecord){
            for(Placement_Content_Detail__c newPcd : list_PlacementContentDetailNew){
                if(newPcd.Id != null) {
                    newMap_PlcContDetail.put(newPcd.Id,newPcd);
                } 
                newMap_PlcCont.put(PlacementContent.Id,PlacementContent); // Placement Content New Map
            }
        }else{
            for(Placement_Content_Detail__c newPcd : list_PlacementContentDetailNew){
                if(newPcd.Id != null) {
                    newMap_PlcContDetail.put(newPcd.Placement_Content_Detail_Self__c,newPcd);
                } 
            }
            newMap_PlcCont.put(PlacementContent.Placement_Content_Self__c,PlacementContent); // Placement Content New Map
        }
        
        // Query to get the Old Version of the Record
        Placement_Content__c plcContent = new Placement_Content__c();
        
        String contentQuery = DGTL_DataAccessor.getSobjectSoql(PlacementContent);
        if(parentRecord){
            contentQuery += ' AND Id =\''+String.escapeSingleQuotes(PlacementContent.Id)+'\'';
        }else{
            contentQuery += ' AND Id =\''+String.escapeSingleQuotes(PlacementContent.Placement_Content_Self__c)+'\'';
        }
        
        list<Placement_Content__c> list_plcContent = Database.query(contentQuery);
        plcContent = list_plcContent[0];  // get the old version of Content
        
        list_PlacementContentDetailOld = plcContent.Placement_Content_Details__r; // get the old list of Content Details
        
        for(Placement_Content__c oldPc : list_plcContent ){
            oldMap_PlcCont.put(oldPc.Id,oldPc);
        }
        
        for(Placement_Content_Detail__c old : list_PlacementContentDetailOld){
            oldMap_PlcContDetail.put(old.Id,old);
        }
        system.debug('list_PlacementContentDetailOld.size().......'+list_PlacementContentDetailOld.size());
        system.debug('list_PlacementContentDetailNew.size().......'+list_PlacementContentDetailNew.size());
        // Check for the Change in Records ----------------------------- Starts
        // check for change in Content Detail Record
        // Case - 1 - if any detail is removed
        if(list_DetelePlacementContentDetail.size() > 0 ){
            ContentDetailChanged = true;
        }// Case 2 - If Fields in Detail have any changes
        else if(list_PlacementContentDetailOld.size() <= list_PlacementContentDetailNew.size()){
            system.debug('... inside the newly added');
            // compare all the records with their fields to identify the changed fields.
            for(Id oldId : oldMap_PlcContDetail.keyset()){
                for(String field : map_DetailWriteFields.keySet()){
                    if(oldMap_PlcContDetail.get(oldId) != null && newMap_PlcContDetail.get(oldId) != null){
                        if(oldMap_PlcContDetail.get(oldId).get(field) != newMap_PlcContDetail.get(oldId).get(field)){
                            changedPCdFields += field+',';
                        }
                    }
                }
                if(String.isNotBlank(changedPCdFields)) map_PCDChangedFields.put(oldId, changedPCdFields.removeEnd(','));
            }
            if(String.isNotBlank(changedPCdFields)) ContentDetailChanged = true;
            if(list_PlacementContentDetailNew.size() > 0){
                system.debug('new --- list_PlacementContentDetailNew...inside');
                for(Placement_Content_Detail__c PCD :list_PlacementContentDetailNew){
                    if(PCD.Id == null){
                        if( String.isNotBlank(PCD.Sub_Type__c) ||  String.isNotBlank(PCD.Copy__c) 
                            ||  String.isNotBlank(PCD.Asset_Path__c) ||  String.isNotBlank(PCD.Link_Text__c)
                           ||  String.isNotBlank(PCD.Slides__c) || String.isNotBlank(PCD.Comments__c)){
                                system.debug('new --- added');
                                system.debug('PCD...'+PCD);
                                ContentDetailChanged = true;
                            }
                    }
                }
            }
             if(String.isNotBlank(changedPCdFields)) system.debug('changedPCdFields...'+changedPCdFields);
        }
        
        for(Id oldPCId : oldMap_PlcCont.keyset()){  // compare all the fields to identify the changed fields.
            for(String field : map_WriteFields.keySet()){
                if(oldMap_PlcCont.get(oldPCId).get(field) != newMap_PlcCont.get(oldPCId).get(field)){
                    changedPlcContFields += field+',';
                }
            }
        }
        changedPlcContFields = changedPlcContFields.removeEnd(',');
        if(String.isNotBlank(changedPlcContFields)) ContentChanged = true; // if Content Changed
        
        // Check for the Change in Records -----------------------------Ends        
        
        if(parentRecord){
            // Prepare the Updated version of Placement Content and its details
            if(ContentChanged || ContentDetailChanged){
                contentRecord = PlacementContent.clone();
                contentRecord.Type__c = 'Escalation';
                contentRecord.Placement_Library__c = PlacementContent.Placement_Library__c;
                contentRecord.Placement_Content_Self__c = PlacementContent.Id;
                contentRecord.Unique_Field__c = contentRecord.Type__c +'-'+contentRecord.Placement_Layout__c +'-'+contentRecord.Placement_Library__c;
                insert contentRecord; // insert to get the New Placement  Content Id
                system.debug('contentRecord..... insert after clone...PC..'+contentRecord);
                
                for(Placement_Content_Detail__c newPCD : list_PlacementContentDetailNew){
                    if(newPCD.Id != null){
                        Placement_Content_Detail__c clonedPCD = newPCD.clone();
                        clonedPCD.Placement_Content_Detail_Self__c = newPCD.Id;
                        clonedPCD.Placement_Content__c = contentRecord.Id;
                        list_PlacementContentDetailCloned.add(clonedPCD);
                    }else{
                        if( String.isNotBlank(newPCD.Sub_Type__c) ||  String.isNotBlank(newPCD.Copy__c) 
                            ||  String.isNotBlank(newPCD.Asset_Path__c) ||  String.isNotBlank(newPCD.Link_Text__c) || 
                           String.isNotBlank(newPCD.Slides__c) || String.isNotBlank(newPCD.Comments__c)){
                                newPCD.Placement_Content__c = contentRecord.Id;
                                newPCD.Placement_Content_Detail_Self__c = null;
                                list_PlacementContentDetailCloned.add(newPCD);
                            }
                    }
                }
                upsert list_PlacementContentDetailCloned;
                
                if(list_DetelePlacementContentDetail.size() > 0){
                    for(Placement_Content_Detail__c delPCD :list_DetelePlacementContentDetail)
                    {   
                        Placement_Content_Detail__c delRec = delPCD.clone();
                        delRec.Is_Deleted__c = true;
                        delrec.Placement_Content__c = contentRecord.Id;
                        delRec.Placement_Content_Detail_Self__c = delPCD.Id;
                        list_OriginalPlacementContentDetailDelete.add(delRec);
                    }        
                    upsert list_OriginalPlacementContentDetailDelete;
                }
                
                if(list_DetelePlacementContentDetailOld.size() >0){
                    for(Placement_Content_Detail__c pcdDelRec : list_DetelePlacementContentDetailOld){
                        if(pcdDelRec.Is_Deleted__c == true && pcdDelRec.Placement_Content_Detail_Self__c != null && !list_OriginalPlacementContentDetailDelete.contains(pcdDelRec)) list_OriginalPlacementContentDetailDelete.add(pcdDelRec);
                    }
                }
                
                for(Placement_Content_Detail__c newPcd : list_PlacementContentDetailCloned){ // Newly added content details
                    if(newPcd.Placement_Content_Detail_Self__c == null) list_AddedPlacementContentDetail.add(newPcd); 
                }
                Changed = true;
                // Create /  Update Task
                createUpdateTask(Changed , changedPlcContFields, map_PCDChangedFields, oldMap_PlcCont, newMap_PlcCont,
                                 oldMap_PlcContDetail , newMap_PlcContDetail,
                                 PlacementContent, contentRecord, list_OriginalPlacementContentDetailDelete,
                                 list_AddedPlacementContentDetail);
            }
            
        }else if(!parentRecord){ // if update Record available
            // Prepare the Updated version of Placement Content and its details
            if(ContentChanged || ContentDetailChanged){
                contentRecord = PlacementContent;
                contentRecord.Unique_Field__c = contentRecord.Type__c +'-'+contentRecord.Placement_Layout__c +'-'+contentRecord.Placement_Library__c;
                upsert contentRecord; // update the New Placement  Content Id
                
                for(Placement_Content_Detail__c newPCD : list_PlacementContentDetailNew){
                    if(newPCD.Id != null){
                        newPCD.Placement_Content__c = contentRecord.Id;
                        list_PlacementContentDetailCloned.add(newPCD);
                    }
                    else{
                        if( String.isNotBlank(newPCD.Sub_Type__c) ||  String.isNotBlank(newPCD.Copy__c) 
                            ||  String.isNotBlank(newPCD.Asset_Path__c) ||  String.isNotBlank(newPCD.Link_Text__c) || 
                           String.isNotBlank(newPCD.Slides__c) || String.isNotBlank(newPCD.Comments__c)){
                                newPCD.Placement_Content_Detail_Self__c = null;
                                list_PlacementContentDetailCloned.add(newPCD);
                            }
                    }
                }
                upsert list_PlacementContentDetailCloned;
                
                if(list_DetelePlacementContentDetail.size() > 0){
                    for(Placement_Content_Detail__c delPCD :list_DetelePlacementContentDetail)
                    {
                        delPCD.Is_Deleted__c = true;
                    }        
                    upsert list_DetelePlacementContentDetail;
                }
                
                if(list_DetelePlacementContentDetailOld.size() >0){
                    for(Placement_Content_Detail__c pcdDelRec : list_DetelePlacementContentDetailOld){
                        if(pcdDelRec.Is_Deleted__c == true && pcdDelRec.Placement_Content_Detail_Self__c != null && !list_DetelePlacementContentDetail.contains(pcdDelRec)) list_DetelePlacementContentDetail.add(pcdDelRec);
                    }   
                }
                
                for(Placement_Content_Detail__c newPcd : list_PlacementContentDetailCloned){ // Newly added content details
                    system.debug('newPcd....'+newPcd);
                    if(newPcd.Placement_Content_Detail_Self__c == null) list_AddedPlacementContentDetail.add(newPcd); 
                }
                Changed = true;
                // Create /  Update Task
                createUpdateTask(Changed, changedPlcContFields, map_PCDChangedFields, oldMap_PlcCont, newMap_PlcCont,
                                 oldMap_PlcContDetail , newMap_PlcContDetail,
                                 PlacementContent, contentRecord, list_DetelePlacementContentDetail,
                                 list_AddedPlacementContentDetail);
            }
        }
        
        system.debug('ContentChanged.......'+ContentChanged);
        system.debug('ContentDetailChanged.......'+ContentDetailChanged);
        if(ContentChanged || ContentDetailChanged) return true;
        else return false;
    }
    
    Public Static void createUpdateTask( Boolean Changed,String ChangedContentFields, map<Id,String> map_PCDChangedFields,
                                        map<Id,Placement_Content__c> oldMap_PlcCont,  map<Id,Placement_Content__c> newMap_PlcCont,  
                                        map<Id,Placement_Content_Detail__c> oldMap_PlcContDetail , map<Id,Placement_Content_Detail__c> newMap_PlcContDetail,
                                        Placement_Content__c oldPlacementContent, Placement_Content__c ClonedContentRecord,
                                        list<Placement_Content_Detail__c> list_DetelePlacementContentDetail,
                                        list<Placement_Content_Detail__c> list_AddedPlacementContentDetail)
    {
        Placement_Content__c oldRec = new  Placement_Content__c();
        
        system.debug('list_DetelePlacementContentDetail...'+list_DetelePlacementContentDetail);
        system.debug('ClonedContentRecord.Id....'+ClonedContentRecord.Id);
        
        Id TaskRecordTypeId = Schema.SObjectType.DGTL_Task__c.getRecordTypeInfosByName().get('Escalation').getRecordTypeId(); 
        List<DGTL_Task__c>  list_Task = [SELECT Id, Name , Status__c ,Placement_Content__c 
                                         FROM DGTL_Task__c WHERE RecordTypeId =: TaskRecordTypeId
                                         AND Placement_Content__c =: ClonedContentRecord.Id 
                                         AND Status__c = 'New'];
        
        DGTL_Task__c taskRec = New DGTL_Task__c();
        
        // Access management recordTypeId for For - Field Access
        Id recordTypeId = Schema.SObjectType.DGTL_Access_Management__c.getRecordTypeInfosByName().get('Field Access').getRecordTypeId();
        
        // Access management record for Placement_Content__c
        DGTL_Access_Management__c accessRecordPC = DGTL_DataAccessor.getAccessMang(oldPlacementContent.Brand__c,oldPlacementContent.Placement_Page_Type__c,
                                                                                   'Placement_Content__c',
                                                                                   'DGTL Main', recordTypeId);
        
        if(!list_Task.isEmpty()){ // update existing task
            system.debug('update-----task----');
            taskRec = list_Task[0];
            taskRec.Status__c = 'New';
            taskRec.DGTL_TaskOwner__c = accessRecordPC.Team__c;
            
        }else{ // create New Task
            system.debug('insert-----task----');
            taskRec = New DGTL_Task__c();
            taskRec.Parent_Content__c = oldPlacementContent.Id;
            taskRec.Placement_Content__c = ClonedContentRecord.Id;
            taskRec.Status__c = 'New';
            taskRec.DGTL_TaskOwner__c = accessRecordPC.Team__c;
            taskRec.RecordTypeId = TaskRecordTypeId;
        }
        
        //--------------------------------------Prepare Detail Field Table-----------------------------Start
        String details ='';
        if(String.isNotBlank(ChangedContentFields)){ //------------- Placement Content Changes table
            
            details += '<div> Placement Content Changes <br/>';
            details += '<table border="1" style="border-collapse: collapse"><tr><th> Name </th><th> Changed Field </th><th> Old Value </th><th> New Value </th><th> Modified By </th><th> Modified Date </th></tr>';
            for( Id oldId : oldMap_PlcCont.keyset()){
                for(String field : ChangedContentFields.split(','))
                {   system.debug('ClonedContentRecord...'+ClonedContentRecord);
                 system.debug('ClonedContentRecord..LastModifiedBy.Name..'+ClonedContentRecord.LastModifiedBy.Name);
                 system.debug('oldPlacementContent..LastModifiedBy.Name..'+oldPlacementContent.LastModifiedBy.Name);
                 system.debug('UserInfo.getUserName()...'+UserInfo.getName());
                 
                 system.debug('field....inside -Placement Content Changes...'+field);
                 details += '<tr>';
                 details += '<td>'; details += oldMap_PlcCont.get(oldId).get('Name') != null? oldMap_PlcCont.get(oldId).get('Name') : 'BLANK';details +='</td>';
                 details += '<td> '+field.replace('__c', '').replaceAll('_', ' ')+' </td>';
                 //details += '<td>'; details += oldMap_PlcCont.get(oldId) != null ? oldMap_PlcCont.get(oldId).get(field) : '';  details +='</td>';
                 //details += '<td>'; details += newMap_PlcCont.get(oldId) != null ? newMap_PlcCont.get(oldId).get(field) : '';  details +='</td>';
                 details += '<td>'; details += oldMap_PlcCont.get(oldId).get(field) != null ? oldMap_PlcCont.get(oldId).get(field) : 'BLANK'; details +='</td>';
                 details += '<td>'; details += newMap_PlcCont.get(oldId).get(field) != null ? newMap_PlcCont.get(oldId).get(field) : 'BLANK'; details +='</td>';
                 details += '<td>'; details += UserInfo.getName(); details +='</td>';
                 //details += '<td>'; details += ClonedContentRecord.LastModifiedBy.Name != null ? ClonedContentRecord.LastModifiedBy.Name : ''; details +='</td>';
                 details += '<td>'; details += ClonedContentRecord.LastModifiedDate == null ? System.now() : ClonedContentRecord.LastModifiedDate; details +='</td>' ;
                 //details += '<td>'+ClonedContentRecord.LastModifiedDate +'</td>' ;
                 details += '</tr>';
                } 
            }
            details += '</table></div> <br/>';
        }
        
        if(!map_PCDChangedFields.isEmpty()){ //------------- Placement Content Details Change table
            system.debug('map_PCDChangedFields..'+map_PCDChangedFields);
            details += '<div> Placement Content Details Changes <br/>';
            details += '<table border="1" style="border-collapse: collapse"><th>Old Values</th><th>New Values</th><th>Modified Date</th></tr>';
            
            for(Id PcdId : map_PCDChangedFields.keyset())
            {  
                string Sub_Type; string Copy; string Link_Text; string Asset_Path; String Slides; String Comments;
                if((map_PCDChangedFields.get(PcdId)).contains('Sub_Type__c')) Sub_Type ='yellow';
                if((map_PCDChangedFields.get(PcdId)).contains('Copy__c')) Copy ='yellow';
                if((map_PCDChangedFields.get(PcdId)).contains('Link_Text__c')) Link_Text ='yellow';
                if((map_PCDChangedFields.get(PcdId)).contains('Asset_Path__c')) Asset_Path ='yellow'; 
                if((map_PCDChangedFields.get(PcdId)).contains('Slides__c')) Slides ='yellow'; 
                if((map_PCDChangedFields.get(PcdId)).contains('Comments__c')) Comments ='yellow'; 
                
                details += '<tr>';
                details += '<td><span style="Background-color:'+ +'">'; details += oldMap_PlcContDetail.get(PcdId).get('Slides__c') != null ? oldMap_PlcContDetail.get(PcdId).get('Slides__c') : 'BLANK' ; details +='</span> ,<br/>';
                details += '<span style="Background-color:'+ +'">'; details += oldMap_PlcContDetail.get(PcdId).get('Sub_Type__c') != null ? oldMap_PlcContDetail.get(PcdId).get('Sub_Type__c') : 'BLANK' ; details +='</span> ,<br/>';
                details += '<span style="Background-color:'+ +'">'; details += oldMap_PlcContDetail.get(PcdId).get('Copy__c') != null ? oldMap_PlcContDetail.get(PcdId).get('Copy__c') : 'BLANK'; details +='</span> ,<br/>';
                details += '<span style="Background-color:'+ +'">'; details += oldMap_PlcContDetail.get(PcdId).get('Link_Text__c') != null ? oldMap_PlcContDetail.get(PcdId).get('Link_Text__c') : 'BLANK'; details += '</span> ,<br/>';
                details += '<span style="Background-color:'+ +'">'; details += oldMap_PlcContDetail.get(PcdId).get('Asset_Path__c') != null ? oldMap_PlcContDetail.get(PcdId).get('Asset_Path__c')  : 'BLANK'; details += '</span> ,<br/>';
                details += '<span style="Background-color:'+ +'">'; details += oldMap_PlcContDetail.get(PcdId).get('Comments__c') != null ? oldMap_PlcContDetail.get(PcdId).get('Comments__c')  : 'BLANK'; details += '</span></td>';
                details += '<td><span style="Background-color:'+Slides+'">'; details += newMap_PlcContDetail.get(PcdId).get('Slides__c') != null ? newMap_PlcContDetail.get(PcdId).get('Slides__c') : 'BLANK'; details +='</span> ,<br/>';
                details += '<span style="Background-color:'+Sub_Type+'">'; details += newMap_PlcContDetail.get(PcdId).get('Sub_Type__c') != null ? newMap_PlcContDetail.get(PcdId).get('Sub_Type__c') : 'BLANK'; details +='</span> ,<br/>';
                details += '<span style="Background-color:'+Copy+'">'; details += newMap_PlcContDetail.get(PcdId).get('Copy__c') != null ? newMap_PlcContDetail.get(PcdId).get('Copy__c') : 'BLANK' ; details +='</span> ,<br/>';
                details += '<span style="Background-color:'+Link_Text+'">'; details += newMap_PlcContDetail.get(PcdId).get('Link_Text__c') != null ? newMap_PlcContDetail.get(PcdId).get('Link_Text__c') :'BLANK'; details +='</span> ,<br/>';
                details += '<span style="Background-color:'+Asset_Path+'">'; details += newMap_PlcContDetail.get(PcdId).get('Asset_Path__c') != null ? newMap_PlcContDetail.get(PcdId).get('Asset_Path__c') :'BLANK'; details +='</span >,<br/>';
                details += '<span style="Background-color:'+Comments+'">'; details += newMap_PlcContDetail.get(PcdId).get('Comments__c') != null ? newMap_PlcContDetail.get(PcdId).get('Comments__c') :'BLANK'; details +='</span></td>';
                details += '<td>'; details += newMap_PlcContDetail.get(PcdId).get('LastModifiedDate') == null ? System.now() : newMap_PlcContDetail.get(PcdId).get('LastModifiedDate'); details +='</td>' ;
                details += '</tr>';
            } 
            details += '</table></div> <br/>';
        }
        
        if(!list_AddedPlacementContentDetail.isEmpty()){ //------------- Newly added Placement Content Details Change table
            
            details += '<div>  New Placement Content Details<br/>';
            details += '<table border="1" style="border-collapse: collapse"><tr><th>Field Values</th><th>Modified By</th><th>Modified Date</th></tr>';
            
            for(Placement_Content_Detail__c det : list_AddedPlacementContentDetail){
                details += '<tr>';
                details += '<td><span>';details += det.Slides__c != null ? det.Slides__c : 'BLANK' ; details +='</span> ,<br/>';
                details += '<span>';details += det.Sub_Type__c != null ? det.Sub_Type__c : 'BLANK' ; details +='</span> ,<br/>';
                details += '<span>'; details += det.Copy__c != null ? det.Copy__c : 'BLANK' ; details +='</span> ,<br/>';
                details += '<span>'; details += det.Link_Text__c != null ? det.Link_Text__c : 'BLANK' ; details +='</span> ,<br/>';                
                details += '<span>'; details += det.Asset_Path__c != null ? det.Asset_Path__c : 'BLANK' ; details +='</span> ,<br/>';
                 details += '<span>'; details += det.Comments__c != null ? det.Comments__c : 'BLANK' ; details +='</span></td>';
                //details += '<td>'; details += det.LastModifiedBy.Name != null ? det.LastModifiedBy.Name : '' ; details +='</td>' ;
                details += '<td>'; details += UserInfo.getName(); details +='</td>' ;
                details += '<td>'; details += det.LastModifiedDate == null ? System.now() : det.LastModifiedDate; details +='</td>' ;
                details += '</tr>';
            }
            details += '</table></div><br/>';
        }
        
        if(!list_DetelePlacementContentDetail.isEmpty()){ //------------- Deteled Placement Content Details Change table
            
            list<Placement_Content_Detail__c> list_DeletedOldPDC = new list<Placement_Content_Detail__c>();
            for(Placement_Content_Detail__c detRec : list_DetelePlacementContentDetail){
                if(detRec.Placement_Content_Detail_Self__c != null){
                    list_DeletedOldPDC.add(detRec);
                }
            }
            if(!list_DeletedOldPDC.isEmpty()){
                details += '<div> Deleted Placement Content Details<br/>';
                details += '<table border="1" style="border-collapse: collapse"><tr><th>Field Values</th><th>Modified By</th><th>Modified Date</th></tr>';
                
                for(Placement_Content_Detail__c det : list_DeletedOldPDC){
                    details += '<tr>';
                    details += '<td><span>'; details += det.Slides__c != null ? det.Slides__c : 'BLANK'; details +='</span> ,<br/>';
                    details += '<span>'; details += det.Sub_Type__c != null ? det.Sub_Type__c : 'BLANK'; details +='</span> ,<br/>';
                    details += '<span>'; details += det.Copy__c  != null ? det.Copy__c : 'BLANK' ; details +='</span> ,<br/>';
                    details += '<span>'; details += det.Link_Text__c != null ? det.Link_Text__c : 'BLANK' ; details +='</span> ,<br/>';                
                    details += '<span>'; details += det.Asset_Path__c != null ? det.Asset_Path__c : 'BLANK' ; details +='</span> ,<br/>';
                    details += '<span>'; details += det.Comments__c != null ? det.Comments__c : 'BLANK' ; details +='</span></td>';
                    //details += '<td>'; details += det.LastModifiedBy.Name != null ? det.LastModifiedBy.Name : 'BLANK'; details +='</td>' ;
                    details += '<td>'; details += UserInfo.getName(); details +='</td>' ;
                    details += '<td>'; details += det.LastModifiedDate == null ? System.now() : det.LastModifiedDate; details +='</td>' ;
                    details += '</tr>';
                }
                details += '</table></div><br/>';
            }
        }
        //--------------------------------------Prepare Detail Field Table-----------------------------End
        taskRec.Changed_Content_Fields__c = details;
        upsert taskRec;
        
        system.debug('taskRec....'+taskRec);
        //sendEscalationEmail(taskRec);
        
        // update the parent if content or detail is Updated
        if(Changed){
            for( Id oldId : oldMap_PlcCont.keyset()){
                oldRec = oldMap_PlcCont.get(oldId);
                oldRec.Has_Unapproved__c = true;
            }
            system.debug('oldRec....Updated...'+oldRec.Has_Unapproved__c);// turn on flag for has unapproved changes - on Placement Content
            update oldRec;
        }
        
        return;
    }
    
    @AuraEnabled
    Public Static void sendEscalationEmail(DGTL_Task__c taskObj){
        
        List<DGTL_Task__c> list_TaskObj = New List<DGTL_Task__c>();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        list_TaskObj = [SELECT ID,name,Brand__c,Changed_Content_Fields__c from  DGTL_Task__c where ID =:taskObj.Id LIMIT 1];
        
        string htmlBody = 'Dear User, <br/> <br/>';
        htmlBody += 'There is an Update on Placement Content record, which needs your Approval <br/>';
        htmlBody += 'You can reply Approved / Rejected to this email to save the new Changes<br/>';
        htmlBody += 'Please go through the Changes below <br/><br/>';
        htmlBody += 'Updated Changes <hr/>';
        htmlBody += 'Task Name - '+list_TaskObj[0].Name;
        htmlBody += list_TaskObj[0].Changed_Content_Fields__c;
        htmlBody += 'Thanks, <br/>';
        htmlBody+= 'Team Salesforce. <br/> <br/>';
        htmlBody+= '%%~~'+list_TaskObj[0].Id;
        
        List<EmailServicesAddress> list_EmailServicesAddress = [select Id,LocalPart,EmailDomainName from EmailServicesAddress 
                                                                where Function.FunctionName='DGTL_InboundEmailEscalationTask' LIMIT 1]; 
        if(list_EmailServicesAddress.size() > 0){
            String str_replyToAddress = list_EmailServicesAddress[0].LocalPart+'@'+list_EmailServicesAddress[0].EmailDomainName;
            system.debug('str_replyToAdd...'+str_replyToAddress);
            
            for(GroupMember gm : [SELECT Group.Name, UserOrGroupId, Group.Developername
                                  FROM GroupMember WHERE Group.Name =: list_TaskObj[0].Brand__c+'-Escalation Queue'])
            {system.debug('----Group.Name' + gm.UserOrGroupId);
             system.debug('----Group' + gm);
             Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
             mail.setTargetObjectId(gm.UserOrGroupId);
             mail.setSubject('Placement Content Update - Approval');
             mail.setHtmlBody(htmlBody);
             mail.setSaveAsActivity(false);
             mail.setReplyTo(str_replyToAddress);
             //mail.setReplyTo('dgtl_inboundemailescalationtask@c-1xacpqjd4cbmwdvwxe2cf7za33p4gsqajg4xdpoe38f98wkk81.2c-4iqxuaa.cs59.apex.sandbox.salesforce.com');
             mail.setccAddresses(new list<string>{});
             emails.add(mail);
            }
        }
        
        if(emails.size() > 0 ) Messaging.sendEmail(emails);
        return; 
    }  
    
    Public Static DGTL_UpdateWraper sendParentContentAndDetail(Placement_Content__c plcContent){
        DGTL_UpdateWraper DGTL_ResWraper = New DGTL_UpdateWraper();
        DGTL_ResWraper.PlacementContent = plcContent;
        List<Placement_Content_Detail__c> list_PlacementContentDetail = new List<Placement_Content_Detail__c>();
        List<Placement_Content_Detail__c> list_DetelePlacementContentDetail = new List<Placement_Content_Detail__c>();
        
        if(plcContent.Content_Type__c == 'Carousel' ){
            DGTL_ResWraper.hideSubType = true;
        }
        
        for( Placement_Content_Detail__c detRec : plcContent.Placement_Content_Details__r){
            if(detRec.Is_Deleted__c) list_DetelePlacementContentDetail.add(detRec);
            else list_PlacementContentDetail.add(detRec);
        }
        DGTL_ResWraper.list_PlacementContentDetail = list_PlacementContentDetail;
        DGTL_ResWraper.list_DetelePlacementContentDetailOld = list_DetelePlacementContentDetail;
        
        return DGTL_ResWraper;
    }
    
    Public Class DGTL_UpdateWraper{
        
        @AuraEnabled DGTL_Task__c activeTaskRec {get;set;}
        @AuraEnabled Boolean parentRecord {get;set;}
        @AuraEnabled Boolean hideSubType {get;set;}
        @AuraEnabled Placement_Content__c PlacementContent {get;set;}
        @AuraEnabled List<Placement_Content_Detail__c> list_PlacementContentDetail {get;set;}
        @AuraEnabled List<Placement_Content_Detail__c> list_DetelePlacementContentDetail {get;set;}
        @AuraEnabled List<Placement_Content_Detail__c> list_DetelePlacementContentDetailOld {get;set;}
        @AuraEnabled Map<String,String> map_ReadFields {get;set;}
        @AuraEnabled Map<String,String> map_DetailReadFields {get;set;}
        @AuraEnabled Map<String,String> map_WriteFields {get;set;}
        @AuraEnabled Map<String,String> map_DetailWriteFields {get;set;}
        
        Public DGTL_UpdateWraper(){
            activeTaskRec = new DGTL_Task__c();
            hideSubType = false;
            parentRecord = false;
            PlacementContent = new Placement_Content__c();
            list_PlacementContentDetail = New List<Placement_Content_Detail__c>();
            list_DetelePlacementContentDetail = New List<Placement_Content_Detail__c>();
            map_ReadFields = New Map<String,String>();
            map_DetailReadFields = New Map<String,String>();
            map_WriteFields  = New Map<String,String>();
            map_DetailWriteFields = New Map<String,String>();
        }
    }
}