global class DGTL_Snapshot_SCH implements Schedulable {
    
    global void execute(SchedulableContext sc){  
        
         String layoutFields = getAllFields('Placement_Layout__c');
        //Select all the layouts and layout contents where the type="layout" and LastModifiedDate =today()
        list<Placement_Layout__c> layoutList = new list<Placement_Layout__c>();        
        String listQuery = 'SELECT id' + layoutFields;
		string layoutType = 'Layout';
        Date today = system.today();
        listQuery += ' FROM Placement_Layout__c  WHERE Type__c =:layoutType and LastModifiedDate >=:today';
        layoutList = Database.query(listQuery);   
        Savepoint sp = Database.setSavepoint();     
        try{
            
            map<string, list<string>> map_ChildsToClone = new map<string, list<string>>();
            map_ChildsToClone.put('Placement_Layout__c', new list<string>{'Placement_Content__c'});
            map_ChildsToClone.put('Placement_Content__c', new list<string>{'Placement_Content_Detail__c'});
            map<string, map<string, string>> map_StaticValues = new map<string, map<string, string>>();
            String todayDate = String.valueOf(date.today());
            map_StaticValues.put('Placement_Layout__c', new map<string, string>{'Type__c' => 'Snapshot', 'Snapshot_Date__c' => todayDate});

            DGTL_GenericMultiLevelClone.deepCloneBatched(layoutList, 
                                                        map_ChildsToClone, 
                                                        map_StaticValues );     
        }catch(exception e){
            Database.rollback(sp);
            system.debug('Error messages : '+e.getMessage());
        }        
    }   
     // Method to get list of field api's as string from diffrent object
    public static String getAllFields(String objectApiName){
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(objectApiName).getDescribe().fields.getMap();
        string queryFields = '';
        for(String s : fieldMap.keyset()){
            if(!queryFields.contains(s) && s.toUpperCase() != 'ID') queryFields += ',' + s;
        }
        return queryFields;
    } 
}