public class DGT_cascadeContentCtr 
{
    @AuraEnabled
    public static mainReturnDataWpr fetchContents(String recId)
    {
        mainReturnDataWpr rWpr = new mainReturnDataWpr();
        Placement_Content__c pCon = [SELECT Id,Placement_Layout__c,Placement_Library__c,Placement_Layout__r.Device_Type__c,
                                     Placement_Layout__r.Brands__c,Placement_Layout__r.Time_No__c,Placement_Layout__r.Date_Formula__c,Type__c,
                                     Placement_Layout__r.Page_Types__c,(select id,Name,KOD__c,KOD__r.Name from Layouts_KODs__r) FROM Placement_Content__c WHERE Id =: recId];
        
        Id RecordTypeId = Schema.SObjectType.DGTL_Access_Management__c.getRecordTypeInfosByName().get('Field Access').getRecordTypeId();
        DGTL_Access_Management__c pContentAccMgt = DGTL_DataAccessor.getAccessMang(pCon.Placement_Layout__r.Brands__c, pCon.Placement_Layout__r.Page_Types__c, 'Placement_Content__c', 'DGTL Main',RecordTypeId);
        DGTL_Access_Management__c pContentDetAccMgt = DGTL_DataAccessor.getAccessMang(pCon.Placement_Layout__r.Brands__c, pCon.Placement_Layout__r.Page_Types__c, 'Placement_Content_Detail__c', 'Layout - Content Details',RecordTypeId); 
        system.debug('pContentAccMgt..'+pContentAccMgt);
        system.debug('pContentDetAccMgt..'+pContentDetAccMgt);
        
        if((pContentAccMgt != null ) && (pContentDetAccMgt != null && String.isNotBlank(pContentDetAccMgt.Writable_Fields__c)))
        {
            Map<String, Schema.SObjectField> map_PlConfields = Schema.getGlobalDescribe().get('Placement_Content__c').getDescribe().fields.getMap();
            Map<String, Schema.SObjectField> map_PlConDetfields = Schema.getGlobalDescribe().get('Placement_Content_Detail__c').getDescribe().fields.getMap();
            Set<String> list_AllContentFields = new Set<String>();  list<String> list_ContentReadFields = new list<String>();
            list<String> list_ContentWriteFields = new list<String>();
            if(String.isNotBlank(pContentAccMgt.Writable_Fields__c)) list_AllContentFields.addAll(pContentAccMgt.Writable_Fields__c.split(';')); 
            if(String.isNotBlank(pContentAccMgt.Read_Only_Fields__c)) list_AllContentFields.addAll(pContentAccMgt.Read_Only_Fields__c.split(';'));
           
            if(String.isNotBlank(pContentAccMgt.Read_Only_Fields__c)) list_ContentReadFields.addAll(pContentAccMgt.Read_Only_Fields__c.split(';'));
            if(String.isNotBlank(pContentAccMgt.Writable_Fields__c)) list_ContentWriteFields.addAll(pContentAccMgt.Writable_Fields__c.split(';')); 

            
            
           // String fieldsToDisplay = String.isNotBlank(pContentAccMgt.Writable_Fields__c) ? pContentAccMgt.Writable_Fields__c : 
           // String.isNotBlank(pContentAccMgt.Read_Only_Fields__c) ? pContentAccMgt.Read_Only_Fields__c : null;
            
            String mainConquery = 'SELECT Id,Name,';
            //mainConquery += fieldsToDisplay != null ? (','+ String.join(fieldsToDisplay.split(';'), ',')) : '';
            //----- Querying Read and  write fields
            if(list_AllContentFields.size() > 0){
                for( String field : list_AllContentFields){
                    mainConquery += field+',';
                } 
            }
            // Get kods 
            if(String.isNotBlank(pContentAccMgt.Button__c) && pContentAccMgt.Button__c.contains('Add KOD')){
                system.debug('----kod if condition');
                mainConquery += '(select id,Name,KOD__c,KOD__r.Name from Layouts_KODs__r),';
            }
            mainConquery   += '(SELECT Id,'+String.join(pContentDetAccMgt.Writable_Fields__c.split(';'), ',')+' FROM Placement_Content_Details__r) FROM Placement_Content__c WHERE Id =: recId';
            contentWpr mainCon = new contentWpr();system.debug(mainConquery);
            Placement_Content__c main_pCon = Database.query(mainConquery);
            mainCon.plContent = main_pCon;
            for(Placement_KOD__c kod : main_pCon.Layouts_KODs__r){
                rWpr.linkedKods += kod.KOD__r.Name + ', ';
            }
            rWpr.linkedKods = rWpr.linkedKods.removeEnd(', ');
            Map<String,List<String>> map_PlcDetFieldValus = new Map<String,List<String>>();
            //if(fieldsToDisplay != null ){
               // for(String mpcField : fieldsToDisplay.split(';'))
            if(list_AllContentFields.size() != null ){
                for(String mpcField : list_AllContentFields)
                {
                    if(map_PlConfields.get(mpcField) != Null)
                    {
                        fieldDataWpr mpcData = new fieldDataWpr();
                        mpcData.fieldApi = mpcField;
                        mpcData.fieldLabel = map_PlConfields.get(mpcField).getDescribe().getLabel();
                        mpcData.fieldType = getFieldType(mpcField,map_PlConfields);
                        if(mpcData.fieldType == 'boolean')
                        {
                            mpcData.actualBooleanVal = Boolean.valueof(main_pCon.get(mpcField.trim()));
                            mpcData.newBooleanVal = Boolean.valueof(main_pCon.get(mpcField.trim()));
                        }
                        
                        mpcData.actualFieldValue = String.valueof(main_pCon.get(mpcField.trim()));
                        mpcData.newFieldValue = String.valueof(main_pCon.get(mpcField.trim()));
                        if(list_ContentReadFields.contains(mpcField) && !list_ContentWriteFields.contains(mpcField)){
                            mpcData.isReadOnly = true;
                        }
                        mainCon.list_PlContentFieldData.add(mpcData);
                    }
                }
            }
            if(!main_pCon.Placement_Content_Details__r.isEmpty())
            {
                for(Placement_Content_Detail__c mpcd : main_pCon.Placement_Content_Details__r)
                {
                    contentDetWpr mpcdWpr = new contentDetWpr();
                    mpcdWpr.plContentDetail = mpcd;
                    
                    for(String mpcdField : pContentDetAccMgt.Writable_Fields__c.split(';'))
                    {
                        if(map_PlConDetfields.get(mpcdField) != Null)
                        {
                            fieldDataWpr mpcdData = new fieldDataWpr();
                            mpcdData.fieldApi = mpcdField;
                            mpcdData.fieldLabel = map_PlConDetfields.get(mpcdField).getDescribe().getLabel();
                            mpcdData.fieldType = getFieldType(mpcdField,map_PlConDetfields);
                            if(mpcdData.fieldType == 'boolean')
                            {
                                mpcdData.actualBooleanVal = Boolean.valueof(mpcd.get(mpcdField.trim()));
                                mpcdData.newBooleanVal = Boolean.valueof(mpcd.get(mpcdField.trim()));
                            }
                            
                            mpcdData.actualFieldValue = String.valueof(mpcd.get(mpcdField.trim()));
                            mpcdData.newFieldValue = String.valueof(mpcd.get(mpcdField.trim()));
                            if(map_PlcDetFieldValus.get(mpcdField) == Null) map_PlcDetFieldValus.put(mpcdField,new List<String>());
                            map_PlcDetFieldValus.get(mpcdField).add('Promote: '+(!String.isBlank(String.valueof(mpcd.get(mpcdField.trim()))) ? String.valueof(mpcd.get(mpcdField.trim())) : ''));
                            mpcdData.lis_ChooseOptions = map_PlcDetFieldValus.get(mpcdField);
                            mpcdWpr.list_PlcConDetFieldData.add(mpcdData);
                        }
                    }
                    mainCon.list_contentDetWpr.add(mpcdWpr);
                }
            }
            rWpr.isContentReadOnly = String.isBlank(pContentAccMgt.Writable_Fields__c) && String.isNotBlank(pContentAccMgt.Read_Only_Fields__c) ? true : false;
            rWpr.mainPlcContent = mainCon;
            rWpr.map_PlcDetFieldValusMain = map_PlcDetFieldValus;
            String pLibraryId = pCon.Placement_Library__c;
            Date dateVal = pCon.Placement_Layout__r.Date_Formula__c;
            Decimal timeVal = pCon.Placement_Layout__r.Time_No__c;
            String deviceType = pCon.Placement_Layout__r.Device_Type__c;
            String query = 'SELECT Id,Name,Brand__c,Editorial_Name__c,' ;
            if(list_AllContentFields.size() > 0){
                for( String field : list_AllContentFields){
                    if(!field.equalsIgnoreCase('Brand__c') && !field.equalsIgnoreCase('Editorial_Name__c')) query += field+',';
                } 
            }
            
            String detailFields = String.join(pContentDetAccMgt.Writable_Fields__c.split(';'), ',');
            detailFields += !detailFields.contains('Brand__c') ? ',Brand__c' : '';
            String contentType = pCon.Type__c;
            //query += fieldsToDisplay != null ? ','+ String.join(fieldsToDisplay.split(';'), ',') : '';
            query += '(SELECT Id,'+detailFields+' FROM Placement_Content_Details__r),(select id,Name,KOD__c,KOD__r.Name from Layouts_KODs__r) FROM Placement_Content__c WHERE Placement_Library__c =: pLibraryId AND Id !=: recId AND Placement_Layout__r.Type__c=\'Layout\' AND Active__c = true AND (Type__c =:contentType)';
            query +=' AND ( Placement_Layout__r.Date_Formula__c >:dateVal OR (Placement_Layout__r.Date_Formula__c =:dateVal AND Placement_Layout__r.Time_No__c >: timeVal) OR (Placement_Layout__r.Date_Formula__c =:dateVal AND Placement_Layout__r.Time_No__c >=: timeVal)) Order By Placement_Layout__r.Date_Formula__c '; //AND Placement_Layout__r.Device_Type__c !=:deviceType
            system.debug('query...'+query);
            for(Placement_Content__c pc : Database.query(query))
            {   
                contentWpr rltdCon = new contentWpr();
                rltdCon.plContent = pc;
                for(Placement_KOD__c kod : pc.Layouts_KODs__r){
                     rltdCon.linkedKods += kod.KOD__r.Name + ', ';
                     rltdCon.oldlinkedKods += kod.KOD__r.Name + ', ';
                   }
                 if(rltdCon.linkedKods.contains(', '))
                 rltdCon.linkedKods = rltdCon.linkedKods.removeEnd(', ');
                 if(rltdCon.oldlinkedKods.contains(', '))
                 rltdCon.oldlinkedKods = rltdCon.oldlinkedKods.removeEnd(', ');
                //if(fieldsToDisplay != null ){
                // for(String pcField : fieldsToDisplay.split(';'))
                if(list_AllContentFields.size() != null ){
                    for(String pcField : list_AllContentFields)
                    {
                        if(map_PlConfields.get(pcField) != Null)
                        {
                            fieldDataWpr pcData = new fieldDataWpr();
                            pcData.fieldApi = pcField;
                            pcData.fieldLabel = map_PlConfields.get(pcField).getDescribe().getLabel();
                            pcData.fieldType = getFieldType(pcField,map_PlConfields);
                            if(pcData.fieldType == 'boolean')
                            {
                                pcData.actualBooleanVal = Boolean.valueof(pc.get(pcField.trim()));
                                pcData.newBooleanVal = Boolean.valueof(pc.get(pcField.trim()));
                            }
                            
                            pcData.actualFieldValue = String.valueof(pc.get(pcField.trim()));
                            pcData.newFieldValue = String.valueof(pc.get(pcField.trim()));
                            pcData.lis_ChooseOptions.add('Actual: '+(!String.isBlank(String.valueof(pc.get(pcField.trim()))) ? String.valueof(pc.get(pcField.trim())) : ''));
                            pcData.lis_ChooseOptions.add('Promote: '+(!String.isBlank(String.valueof(main_pCon.get(pcField.trim()))) ? String.valueof(main_pCon.get(pcField.trim())) : ''));
                            rltdCon.list_PlContentFieldData.add(pcData);
                        }
                    }
                }
                if(!pc.Placement_Content_Details__r.isEmpty())
                {
                    for(Placement_Content_Detail__c pcd : pc.Placement_Content_Details__r)
                    {
                        contentDetWpr pcdWpr = new contentDetWpr();
                        pcdWpr.plContentDetail = pcd;
                        
                        for(String pcdField : pContentDetAccMgt.Writable_Fields__c.split(';'))
                        {
                            if(map_PlConDetfields.get(pcdField) != Null)
                            {
                                fieldDataWpr pcdData = new fieldDataWpr();
                                pcdData.fieldApi = pcdField;
                                pcdData.fieldLabel = map_PlConDetfields.get(pcdField).getDescribe().getLabel();
                                pcdData.fieldType = getFieldType(pcdField,map_PlConDetfields);
                                if(pcdData.fieldType == 'boolean')
                                {
                                    pcdData.actualBooleanVal = Boolean.valueof(pcd.get(pcdField.trim()));
                                    pcdData.newBooleanVal = Boolean.valueof(pcd.get(pcdField.trim()));
                                }
                                
                                pcdData.actualFieldValue = String.valueof(pcd.get(pcdField.trim()));
                                pcdData.newFieldValue = String.valueof(pcd.get(pcdField.trim()));
                                pcdData.lis_ChooseOptions.add('Actual: '+(!String.isBlank(String.valueof(pcd.get(pcdField.trim()))) ? String.valueof(pcd.get(pcdField.trim())) : ''));
                                if(map_PlcDetFieldValus.get(pcdField) != Null) pcdData.lis_ChooseOptions.addAll(map_PlcDetFieldValus.get(pcdField)	);
                                pcdWpr.list_PlcConDetFieldData.add(pcdData);
                            }
                        }
                        rltdCon.list_contentDetWpr.add(pcdWpr);
                    }
                }
                rWpr.list_PlcContents.add(rltdCon);
            }
            rWpr.status = 'success';
            rWpr.message = '';
        }
        else
        {
            rWpr.status = 'error';
            rWpr.message = 'No Access records found for you/the current Content Brand..!!';
        }
        return rWpr;
    }
    @AuraEnabled
    public static contentDetWpr addNewPlConDet(String plcId,contentDetWpr selectedPlcDet)
    {
        contentDetWpr pcdWpr = new contentDetWpr();
        pcdWpr.plContentDetail = new Placement_Content_Detail__c();
        pcdWpr.plContentDetail.Placement_Content__c = plcId;
        for(fieldDataWpr f : selectedPlcDet.list_PlcConDetFieldData)
        {
            if(f.fieldType == 'boolean')
            pcdWpr.plContentDetail.put(f.fieldApi,Boolean.valueOf(f.newFieldValue));             
            else
            pcdWpr.plContentDetail.put(f.fieldApi,f.newFieldValue);
            
        }
        pcdWpr.list_PlcConDetFieldData = selectedPlcDet.list_PlcConDetFieldData;
        System.debug('@@==>> pcdWpr: '+pcdWpr.list_PlcConDetFieldData);
        return pcdWpr;
    }
    
    @AuraEnabled
    public static List<contentDetWpr> promotePlConDets(String plcId,List<contentDetWpr> list_AllMainPlcCOnDet)
    {
        List<contentDetWpr> list_contentDetWpr = new List<contentDetWpr>();
        for(contentDetWpr cWpr : list_AllMainPlcCOnDet)
        {
            contentDetWpr pcdWpr = new contentDetWpr();
            pcdWpr.plContentDetail = cWpr.plContentDetail.clone();
            pcdWpr.plContentDetail.Placement_Content__c = (String.isNotBlank(plcId)) ? plcId : null;
            pcdWpr.list_PlcConDetFieldData = cWpr.list_PlcConDetFieldData;
            list_contentDetWpr.add(pcdWpr);
        }
        
        System.debug('@@==>> pcdWpr: '+list_contentDetWpr);
        return list_contentDetWpr;
    }
    
   /* @AuraEnabled
    public static String saveContents(List<Placement_Content__c> list_NewPlcContents,List<Placement_Content_Detail__c> list_NewPlcConDets, List<String> detailIds,boolean linkKODs,list<string> selContKod,string contId)
    {
        system.debug('@@@==>> Detail: '+list_NewPlcConDets);
        system.debug('@@@==>> contents: '+JSON.serialize(list_NewPlcContents));
        try{
            List<sObject> contentsByPermissionList;
            List<sObject> contentDetailsByPermissionList;
            Map<String,List<sObject>> objListMap = new Map<String,List<sObject>>();
            
            if(list_NewPlcContents.size() > 0){objListMap.put('Placement_Content__c',list_NewPlcContents);}
            
            if(list_NewPlcConDets.size() > 0){ objListMap.put('Placement_Content_Detail__c',list_NewPlcConDets); }
            
            if(objListMap.size() > 0){
                Map<String,List<sObject>> convertedObjListMap = DGTL_Util.getConvertedData(objListMap);
                
                if(convertedObjListMap.containsKey('Placement_Content__c')){
                    contentsByPermissionList = (List<SObject>)Type.forName('List<Placement_Content__c>').newInstance();
                    contentsByPermissionList.addAll(convertedObjListMap.get('Placement_Content__c'));
                    upsert contentsByPermissionList;
                }
                
                if(convertedObjListMap.containsKey('Placement_Content_Detail__c')){
                    contentDetailsByPermissionList = (List<SObject>)Type.forName('List<Placement_Content_Detail__c>').newInstance();
                    contentDetailsByPermissionList.addAll(convertedObjListMap.get('Placement_Content_Detail__c'));
                    upsert contentDetailsByPermissionList;
                }
                // Adding linked kods
                if(linkKODs){
                    list<Placement_KOD__c> list_KodInsert = new list<Placement_KOD__c>();
                    list<Placement_KOD__c> list_KodDelete = new list<Placement_KOD__c>();
                    for(Placement_KOD__c kod : [select Id,KOD__c,Placement_Content__c,Placement_Library__c from Placement_KOD__c where Placement_Content__c IN : selContKod])
                    {
                        list_KodDelete.add(kod);
                    }
                    if(!list_KodDelete.isEmpty()){
                        delete list_KodDelete;
                    }

                    for(Placement_KOD__c kod : [select Id,KOD__c,Placement_Content__c,Placement_Library__c from Placement_KOD__c where Placement_Content__c=:contId])
                    {
                        for(string conId : selContKod){
                            Placement_KOD__c clonkod = new Placement_KOD__c();
                            clonkod = kod.clone(false, false, false, false);
                            clonkod.Placement_Content__c = conId;
                            list_KodInsert.add(clonkod);
                        }
                    }
                    if(!list_KodInsert.isEmpty()){
                        insert list_KodInsert;
                    }
                }
            }
            
            List<Placement_Content_Detail__c> deletedList = new List<Placement_Content_Detail__c>();
            system.debug('detailIds------'+detailIds);
            if(detailIds.size() > 0){
                deletedList = [Select id, Name from Placement_Content_Detail__c where id in :detailIds ];
                system.debug('deletedList ---'+deletedList);
                delete deletedList;
            } 
            return 'Success';
        }
        catch(exception e){
            return 'Error: '+String.valueOf(e)+'. At: '+e.getStackTraceString();
        }
    }*/
    
    @AuraEnabled
    public static String saveContents(List<Placement_Content__c> list_NewPlcContents,List<Placement_Content_Detail__c> list_NewPlcConDets, List<String> detailIds,boolean linkKODs,list<string> selContKod,string contId)
    {
        system.debug('@@@==>> Detail: '+list_NewPlcConDets);
        try{
            Upsert list_NewPlcContents;    
            Upsert list_NewPlcConDets;
            
            List<Placement_Content_Detail__c> deletedList = new List<Placement_Content_Detail__c>();
            system.debug('detailIds------'+detailIds);
            
                // Adding linked kods
                if(linkKODs){
                    list<Placement_KOD__c> list_KodInsert = new list<Placement_KOD__c>();
                    list<Placement_KOD__c> list_KodDelete = new list<Placement_KOD__c>();
                    for(Placement_KOD__c kod : [select Id,KOD__c,Placement_Content__c,Placement_Library__c from Placement_KOD__c where Placement_Content__c IN : selContKod])
                    {
                        list_KodDelete.add(kod);
                    }
                    if(!list_KodDelete.isEmpty()){
                        delete list_KodDelete;
                    }

                    for(Placement_KOD__c kod : [select Id,KOD__c,Placement_Content__c,Placement_Library__c from Placement_KOD__c where Placement_Content__c=:contId])
                    {
                        for(string conId : selContKod){
                            Placement_KOD__c clonkod = new Placement_KOD__c();
                            clonkod = kod.clone(false, false, false, false);
                            clonkod.Placement_Content__c = conId;
                            list_KodInsert.add(clonkod);
                        }
                    }
                    if(!list_KodInsert.isEmpty()){
                        insert list_KodInsert;
                    }
                }
            
            if(detailIds.size() > 0){
                deletedList = [Select id, Name from Placement_Content_Detail__c where id in :detailIds ];
                system.debug('deletedList ---'+deletedList);
                delete deletedList;
            } 
            return 'Success';
        }
        catch(exception e){
            return 'Error: '+String.valueOf(e)+'. At: '+e.getStackTraceString();
        }
    }
    
    public static List<fieldDataWpr> mapAllFields()
    {
        List<fieldDataWpr> list_fieldDataWpr = new List<fieldDataWpr>();
        return list_fieldDataWpr;
    }
    public static String getFieldType(String fieldApiName,Map<String,Schema.SObjectField> map_FieldSchema)
    {
        if(map_FieldSchema.get(fieldApiName).getDescribe().getType() == Schema.DisplayType.BOOLEAN)
        {
            return 'boolean';                    
        }
        else if(map_FieldSchema.get(fieldApiName).getDescribe().getType() == Schema.DisplayType.TEXTAREA && 
                map_FieldSchema.get(fieldApiName).getDescribe().isHtmlFormatted())
        {
            return 'richtext'; 
        }
        else
        {
            return 'text'; 
        }
    } 
    
    public class mainReturnDataWpr
    {
        @AuraEnabled public contentWpr mainPlcContent{get;set;}
        @AuraEnabled public List<contentWpr> list_PlcContents{get;set;}
        @AuraEnabled public Map<String,List<String>> map_PlcDetFieldValusMain{get;set;}
        @AuraEnabled public String status{get;set;}
        @AuraEnabled public String message{get;set;}
        @AuraEnabled public Boolean isContentReadOnly{get;set;}
        @AuraEnabled public String linkedKods{get;set;}
        public mainReturnDataWpr()
        {
            mainPlcContent = new contentWpr();
            list_PlcContents = new List<contentWpr>();
            map_PlcDetFieldValusMain = new Map<String,List<String>>();
            status = '';
            message = '';
            isContentReadOnly = false;
            linkedKods = '';
        }
    }
    
    public class contentWpr
    {
        @AuraEnabled public Placement_Content__c plContent{get;set;}
        @AuraEnabled public List<contentDetWpr> list_contentDetWpr{get;set;}
        @AuraEnabled public List<fieldDataWpr> list_PlContentFieldData{get;set;}
        @AuraEnabled public Boolean isContentSelected{get;set;}
        @AuraEnabled public String linkedKods{get;set;}
        @AuraEnabled public String oldlinkedKods{get;set;}
        public contentWpr()
        {
            plContent = new Placement_Content__c();
            list_contentDetWpr = new List<contentDetWpr>();
            list_PlContentFieldData = new List<fieldDataWpr>();
            isContentSelected = false;
            linkedKods = '';
            oldlinkedKods = '';
        }
    }
    public class contentDetWpr
    {
        @AuraEnabled public Placement_Content_Detail__c plContentDetail{get;set;}
        @AuraEnabled public Boolean isNew{get;set;}
        @AuraEnabled public List<fieldDataWpr> list_PlcConDetFieldData{get;set;}
        @AuraEnabled public Boolean isConDetSelected{get;set;}
        public contentDetWpr()
        {
            plContentDetail = new Placement_Content_Detail__c();
            isNew = false;
            list_PlcConDetFieldData = new List<fieldDataWpr>();
            isConDetSelected = false;
        }
    }
    public class fieldDataWpr
    {
        @AuraEnabled public Boolean isChecked{get;set;}
        @AuraEnabled public String fieldLabel{get;set;}
        @AuraEnabled public String fieldApi{get;set;}
        @AuraEnabled public String actualFieldValue{get;set;}
        @AuraEnabled public String newFieldValue{get;set;}
        @AuraEnabled public String fieldType{get;set;}
        @AuraEnabled public Boolean actualBooleanVal{get;set;}
        @AuraEnabled public Boolean newBooleanVal{get;set;}
        @AuraEnabled public List<String> lis_ChooseOptions{get;set;}
        @AuraEnabled public Boolean isReadOnly{get;set;}
        public fieldDataWpr()
        {
            fieldLabel = '';
            fieldApi = '';
            actualFieldValue = '';
            newFieldValue = '';
            fieldType = '';
            actualBooleanVal = false;
            newBooleanVal = false;
            lis_ChooseOptions = new List<String>();
            isChecked = false;
        }
    }
}
