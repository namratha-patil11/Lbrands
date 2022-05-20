public class DGTL_MulticntEditController {
    @AuraEnabled
    public static DGTL_WrapperClasses.LayoutSearchResults fetchContents(String recId)
    { 
        
        DGTL_WrapperClasses.LayoutSearchResults searchResults = new DGTL_WrapperClasses.LayoutSearchResults();
        List<DGTL_WrapperClasses.contentWprNew> list_ContentsWpr = new List<DGTL_WrapperClasses.contentWprNew>();
      
        string layoutDate1  = string.valueOf(system.today());
        
        Placement_Library__c pCon = [SELECT Id,Brands__c,Page_Types__c FROM Placement_Library__c WHERE Id =: recId];
        
        Id RecordTypeId = Schema.SObjectType.DGTL_Access_Management__c.getRecordTypeInfosByName().get('Field Access').getRecordTypeId();
        DGTL_Access_Management__c pContentAccMgt = DGTL_DataAccessor.getAccessMang(pCon.Brands__c, pCon.Page_Types__c, 'Placement_Content__c', 'DGTL Main',RecordTypeId);
        DGTL_Access_Management__c pContentDetAccMgt = DGTL_DataAccessor.getAccessMang(pCon.Brands__c, pCon.Page_Types__c, 'Placement_Content_Detail__c', 'Layout - Content Details',RecordTypeId); 
        system.debug('pContentAccMgt..'+pContentAccMgt);
        system.debug('pContentDetAccMgt..'+pContentDetAccMgt);
        
        if((pContentAccMgt != null ) && (pContentDetAccMgt != null && String.isNotBlank(pContentDetAccMgt.Writable_Fields__c)))
        {
            Map<String, Schema.SObjectField> map_PlConfields = Schema.getGlobalDescribe().get('Placement_Content__c').getDescribe().fields.getMap();
            Map<String, Schema.SObjectField> map_PlConDetfields = Schema.getGlobalDescribe().get('Placement_Content_Detail__c').getDescribe().fields.getMap();
            Set<String> list_AllContentFields = new Set<String>();  list<String> list_ContentReadFields = new list<String>();
            list<String> list_ContentWriteFields = new list<String>();
            
            list<String> list_ContentDetReadFields = new list<String>();  list<String> list_ContentDetWriteFields = new list<String>();
            
            if(String.isNotBlank(pContentAccMgt.Writable_Fields__c)) list_AllContentFields.addAll(pContentAccMgt.Writable_Fields__c.split(';')); 
            if(String.isNotBlank(pContentAccMgt.Read_Only_Fields__c)) list_AllContentFields.addAll(pContentAccMgt.Read_Only_Fields__c.split(';'));
            
            if(String.isNotBlank(pContentAccMgt.Read_Only_Fields__c)) list_ContentReadFields.addAll(pContentAccMgt.Read_Only_Fields__c.split(';'));
            if(String.isNotBlank(pContentAccMgt.Writable_Fields__c)) list_ContentWriteFields.addAll(pContentAccMgt.Writable_Fields__c.split(';')); 
            
            if(String.isNotBlank(pContentDetAccMgt.Read_Only_Fields__c)) list_ContentDetReadFields.addAll(pContentDetAccMgt.Read_Only_Fields__c.split(';'));
            if(String.isNotBlank(pContentDetAccMgt.Writable_Fields__c)) list_ContentDetWriteFields.addAll(pContentDetAccMgt.Writable_Fields__c.split(';'));
     
            String mainConquery = 'SELECT Id,Name,Placement_Layout__r.Name,';
            //mainConquery += fieldsToDisplay != null ? (','+ String.join(fieldsToDisplay.split(';'), ',')) : '';
            //----- Querying Read and  write fields
            if(list_AllContentFields.size() > 0){
                for( String field : list_AllContentFields){
                    mainConquery += field+',';
                } 
                
                mainConquery   += '(SELECT Id,'+String.join(pContentDetAccMgt.Writable_Fields__c.split(';'), ',')+' FROM Placement_Content_Details__r) FROM Placement_Content__c WHERE Placement_Library__c =: recId AND Type__c != \'Escalation\' AND Placement_Layout__r.Date_Formula__c > ' + layoutDate1 + '  AND Formula_Layout_Type__c != \'Snapshot\'';    
                
            }
            system.debug(mainConquery);
            
            list<Placement_Content__c> list_contentList = new list<Placement_Content__c>();
            list_contentList = Database.query(mainConquery);
            
            for(Placement_Content__c each_content : list_contentList){
                
                DGTL_WrapperClasses.contentWprNew newWpr = new DGTL_WrapperClasses.contentWprNew();
                DGTL_WrapperClasses.ContentDetailWrp newdetailwpr = new  DGTL_WrapperClasses.ContentDetailWrp();
                newWpr.pContentRec = each_content;
                newdetailwpr.detailList.addAll(each_content.Placement_Content_Details__r);
                newdetailwpr.detailDeleteList = new list<Placement_Content_Detail__c>();
                newWpr.ContentDetWpr =  newdetailwpr;
                list_ContentsWpr.add(newWpr); //list_contentWpr //ContentDetWpr.detailList
            }
            
            searchResults.list_contentWpr.addAll(list_ContentsWpr);  
            
            map<string,string> map_cnrdFld = new map<string, string>();
            map<string,string> map_cnwtFld = new map<string, string>();
            
            map<string,string> map_cnDtReadFld = new map<string, string>();
            map<string,string> map_cnDtwtFld = new map<string, string>();
            
            
            
            for(string readFld: list_ContentReadFields){
                if(map_PlConfields.get(readFld) != null){
                    if(map_cnrdFld.get(readFld) == null)
                        map_cnrdFld.put(readFld, map_PlConfields.get(readFld).getDescribe().getLabel());
                }
            }
            for(string wrtFld: list_ContentWriteFields){
                if(map_PlConfields.get(wrtFld) != null){
                    if(map_cnwtFld.get(wrtFld) == null)
                        map_cnwtFld.put(wrtFld, map_PlConfields.get(wrtFld).getDescribe().getLabel());
                }
                
            }
            searchResults.editFieldsMap = map_cnwtFld;
            if(searchResults.editFieldsMap.keyset().contains('Image__c')){
                searchResults.timeValStr = 'Image__c';
            }
            else
            {
                searchResults.timeValStr = 'True'; 
            }
            
            searchResults.readFieldsMap = map_cnrdFld;
            
            for(string detReadFld :list_ContentDetReadFields ){
                if(map_PlConDetfields.get(detReadFld) != null)
                {
                    if(map_cnDtReadFld.get(detReadFld) == null){
                        map_cnDtReadFld.put(detReadFld, map_PlConDetfields.get(detReadFld).getDescribe().getLabel());
                    }
                }
                
            }
            
            for(string detwrtFld : list_ContentDetWriteFields){
                if(map_PlConDetfields.get(detwrtFld) != null)
                {
                    if(map_cnDtwtFld.get(detwrtFld) == null){
                        map_cnDtwtFld.put(detwrtFld, map_PlConDetfields.get(detwrtFld).getDescribe().getLabel());
                    }
                }
                
            }
            searchResults.detailReadFieldsMap = map_cnDtReadFld;
            searchResults.detailWriteFieldsMap = map_cnDtwtFld;
            
        }
        return searchResults;    
        
    }
    
    
    @AuraEnabled
    public static String finalSubmitContent(List<DGTL_WrapperClasses.contentWprNew> list_ContentToUpdate)
    {
        Savepoint sp = Database.setSavepoint();        
        try{
            
            boolean isNewLayout = false;
            List<Placement_Content__c> list_UpsertContent = new List<Placement_Content__c>(); // used to create/update contents          
            List<Placement_Content_Detail__c> list_FilteredUpsertDetail = new List<Placement_Content_Detail__c>(); // used to create/update contents
            List<Placement_Content_Detail__c> list_UpsertDetail = new List<Placement_Content_Detail__c>(); // used to create/update contents
            List<Placement_Content_Detail__c> list_DeleteDetail = new List<Placement_Content_Detail__c>(); // used to create/update contents
            Integer i = 1; // used for ordering s no for contents


            for(DGTL_WrapperClasses.contentWprNew cWpr : list_ContentToUpdate)
            {
                Placement_Content__c pcm = cWpr.pContentRec;
                
                list_UpsertContent.add(pcm);system.debug(pcm);
                DGTL_WrapperClasses.ContentDetailWrp contDetail = cWpr.ContentDetWpr;
                list_DeleteDetail.addAll(contDetail.detailDeleteList);  
                list_UpsertDetail.addAll(contDetail.detailList);  
            }

            map<id,id> map_ConLib = new map<id,id>();
            
            if(!list_UpsertContent.isEmpty()) {
                Upsert list_UpsertContent;
                
                for(Placement_Content__c plc : list_UpsertContent){
                    map_ConLib.put(plc.Placement_Library__c, plc.Id);
                }
            }
            if(!list_UpsertDetail.isEmpty()){
                for(Placement_Content_Detail__c detRec : list_UpsertDetail){
                    if(String.isNotBlank(detRec.Sub_Type__c) ||  String.isNotBlank(detRec.Copy__c) 
                       ||  String.isNotBlank(detRec.Asset_Path__c) ||  String.isNotBlank(detRec.Link_Text__c) 
                       ||  String.isNotBlank(detRec.Slides__c) || String.isNotBlank(detRec.Comments__c)){
                           list_FilteredUpsertDetail.add(detRec);
                       }else if(detRec.Id != null){
                            // delete if all are blank
                            list_DeleteDetail.add(detRec);
                        }
                    if(detRec.Placement_Content__c == null) {
                        detRec.Placement_Content__c = map_ConLib.get(detRec.Placement_Library__c);
                        detRec.Placement_Library__c = null;
                    }
                }
            }

            
            if(!list_FilteredUpsertDetail.isEmpty()){
                Upsert list_FilteredUpsertDetail;
            }
            if(!list_DeleteDetail.isEmpty()){
                Delete list_DeleteDetail;
            }
            
            return 'Success';
        }
        catch(exception e){
            
            Database.rollback(sp);
            if(string.valueOf(e).contains('DUPLICATE_VALUE'))                
                return DGTL_ErrorMessages__c.getValues('DGTL_DuplicateLayoutorContent').Error_Message__c;
            return e.getMessage();
        } 
    }
    
}