({
	doInitHpr : function(component, event, helper) {
        
		var sobject = component.get('v.objName');
        var fieldName = component.get('v.fieldName');
        var formatText = component.find("fielddata");
        if(fieldName != undefined  && sobject != undefined) {
            if(!fieldName.includes('.')) {
                if(sobject[fieldName] == undefined || sobject[fieldName] == '' || sobject[fieldName] == null){}
                formatText.set("v.value",sobject[fieldName]);                
            }
            else {
                formatText.set("v.value",sobject[fieldName.split(".")[0]][fieldName.split(".")[1]]); //Here we are fetching data from parent field            
            }
        }
        component.set("v.Valueset", true);
        
	},
    changeHpr: function(component,event,helper){
        
       // console.log('---changed value--'+event.getSource().get('v.value'));        
        if(event.getSource().get('v.value') != undefined){
            var newvalue = event.getSource().get('v.value');
            if(newvalue.constructor === Array ){
            	component.get('v.objName')[component.get("v.fieldName")] = newvalue[0];
            }else{
                component.get('v.objName')[component.get("v.fieldName")] =  newvalue; 
            }
        }
         component.set("v.Valueset", false);
        
    }
})