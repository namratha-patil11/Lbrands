/* Name        : DGTL_History
 * Description : This class is used to get history related to content and content detail
 * Component   : Used in dGTL_HistoryLWC lightning web component
 * Author      : Vidya Sagar
 */
public class DGTL_History {
    
    /*
 	* Name 	      : HistoryRecordsList
	* Description : This method is used to create list of wrapper class with histroy tracking(placement content/placement content detail)
	* Param       : objectId - Record Id of Content/Content detail Id,contEdtFields - list of editable fields of content, contDtEdtFields - list of editable fields of content detail
 	* return      : returns list of wrapperclass
 	*/
    @AuraEnabled(cacheable=true)
    public static list<DGTL_HistoryRecordWrapper> HistoryRecordsList(Id objectId,list<string> contEdtFields,list<string> contDtEdtFields){
        if(!string.isBlank(objectId)){
			list<string> historyFields = new list<string>();
			list<DGTL_HistoryRecordWrapper>   historywrp = new list<DGTL_HistoryRecordWrapper>();
			// history records record type 
			Id historyRecTypeId = Schema.SObjectType.History_Tracking__c.getRecordTypeInfosByName().get('History Records').getRecordTypeId();
			DGTL_HistoryRecordWrapper result = new DGTL_HistoryRecordWrapper(); 
			string objectName = '';
            // get object api name by record id
			objectName = objectId.getSObjectType().getDescribe().getName().replace('__c', '').replaceAll('_', ' ');
            if(objectName == 'Placement Content'){
                // get list of fields from field set from placement content object
                historyFields = getContentHistoryFieldset();
			}
			else if(objectName == 'Placement Content Detail'){
                // get list of fields from field set from placement content detail object
				historyFields = getContentDetailHistoryFieldset();
			}
            // get history records
			for(History_Tracking__c his :[ Select Id,name,Field_Name__c,Old_Value__c,New_Value__c,LastModifiedById,LastModifiedBy.Name,Field_API__c,
                               LastModifiedDate from History_Tracking__c where recordTypeId=:historyRecTypeId 
                               and Object_Name__c = :objectName AND Field_API__c IN : historyFields
                               AND (Placement_Content__c=:objectId OR Placement_Content_Detail__c=:objectId) order by LastModifiedDate desc limit 100])
			 { 
			     // mapping to wrapperclass
			   DGTL_HistoryRecordWrapper objhis = new DGTL_HistoryRecordWrapper();
			   // cheks for field editable of Content and Content detail
               if(!contEdtFields.isEmpty() && contEdtFields.contains(his.Field_API__c) && objectName == 'Placement Content' ){
                   objhis.isEditable = true;
               }else if(!contDtEdtFields.isEmpty() && contDtEdtFields.contains(his.Field_API__c) && objectName == 'Placement Content Detail'){
                   objhis.isEditable = true;
               }			   
               objhis.hisObjName = objectName;               
			   objhis.contHistRec = his;
			   objhis.isSelected = false;
               if(objectName == 'Placement Content' && (objhis.contHistRec.Field_API__c == 'Image__c' || objhis.contHistRec.Field_API__c == 'Copy_Image__c'))
                {
                    objhis.isImage = true;
                }else if(objectName == 'Placement Content Detail' && objhis.contHistRec.Field_API__c == 'Copy__c')
                {
                    objhis.isImage = true;
                }
			   historywrp.add(objhis);
			 }                  
			return historywrp;
           
		}else{
			return null;
		}         
        
    }
    
      
    public class DGTL_HistoryRecordWrapper{
        @AuraEnabled public boolean isSelected {get;set;}
        @AuraEnabled public boolean isEditable {get;set;}
        @AuraEnabled public boolean isImage {get;set;}
        @AuraEnabled public string hisObjName {get;set;}
        @AuraEnabled public History_Tracking__c contHistRec {get;set;}
        
        public DGTL_HistoryRecordWrapper()
        {
            isSelected = false;
            isEditable = false;
            isImage = false;
            contHistRec = New History_Tracking__c(); 
            hisObjName = '';          
        }
        
    }
    
    /*
 	* Name 	      : getContentHistoryFieldset
	* Description : This method is used to get fieldset(Histroy fields) from Histroy object
 	* return      : returns list of fields api names
 	*/
    public static list<string> getContentHistoryFieldset()
    {
        // get placement content histrory fieldset list
        List<Schema.FieldSetMember> list_fldset = SObjectType.Placement_Content__c.FieldSets.DGTL_Content_History_fields.getFields();
        list<string> list_ApiFields = new list<string>();        
        for(Schema.FieldSetMember fld : list_fldset)
        {
            // adding field api name to list 
            list_ApiFields.add(fld.getFieldPath());
        }
        return list_ApiFields;
    }
    
     /*
 	* Name 	      : getContentDetailHistoryFieldset
	* Description : This method is used to get fieldset(Histroy fields) from Histroy object
 	* return      : returns list of fields api names
 	*/
    public static list<string> getContentDetailHistoryFieldset()
    {
        // get placement content histrory fieldset list
        List<Schema.FieldSetMember> list_fldset = SObjectType.Placement_Content_Detail__c.FieldSets.DGTL_Content_Detail_History_Fields.getFields();
        list<string> list_ApiFields = new list<string>();        
        for(Schema.FieldSetMember fld : list_fldset)
        {
            // adding field api name to list 
            list_ApiFields.add(fld.getFieldPath());
        }
        return list_ApiFields;
    }    
   

}