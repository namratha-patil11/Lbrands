({
	
      fetchAllContentsHpr : function(component,event,helper) {
        component.set("v.spinner",true);
        var action = component.get("c.fetchContents");
        var recIds = component.get("v.recordId");
        console.log('recIds --> ' + recIds);
        // alert(recIds);
        action.setParams({'recId':component.get("v.recordId")});
       
        action.setCallback(this,function(result){
          //  alert(result.getState());
           // alert(result.getReturnValue);
            if(result.getState() === 'SUCCESS')
            {
                if(result.getReturnValue() != undefined)
                {
                    var finalRes = result.getReturnValue();
              
                    component.set("v.conDetReadMap", finalRes.detailReadFieldsMap);
                    component.set("v.conDetWriteMap", finalRes.detailWriteFieldsMap);
                    component.set("v.placementContents",finalRes.list_contentWpr);
                    component.set("v.checkImage", finalRes.timeValStr);
                    var listContents = finalRes.list_contentWpr;
               
                    if(listContents.length == 0 || (listContents.constructor === Array && listContents.len == 0)){
                        console.log('@@coming'); 
                        
                        this.showToast(component,'dismissible','Failed','No Contents found for this Library!!','error');
                    }
                    
                
                    var custs = [];
                        var conts = finalRes.readFieldsMap;
                        for ( var key in conts ) {
                            custs.push({value:conts[key], key:key});
                        }                        
                        // mapping read field api name and label
                        var custs2 = [];
                        var conts2 = finalRes.editFieldsMap;
                        for ( var key in conts2 ) {
                            custs2.push({value:conts2[key], key:key});
                        }
                        
                        component.set("v.contreadList",custs);
                        component.set("v.contWriteList",custs2); 
                        
                    component.set("v.spinner",false); 
              
                }
                else
                {  
                    console.log('@@dismissable');
                    component.set("v.spinner",false);
                    this.showToast(component,'dismissible','Failed','Error','error');
                }
            }
            else
            {   console.log('@@dismissable2');
                component.set("v.spinner",false);
                this.showToast(component,'dismissible','Failed','Error','error');
            }
        });
        $A.enqueueAction(action);
    },
    
     updateContentJsHpr : function(component,event, helper) {
        
        component.set("v.spinner",true);
    
        var action = component.get("c.finalSubmitContent");
        action.setParams({                          
                          'list_ContentToUpdate':component.get("v.placementContents"),                         
                          
                         });
        
        action.setCallback(this,function(result){
            var state = result.getState();
            if(state === 'SUCCESS')
            {
                var returnVal = result.getReturnValue();
                if(returnVal !== undefined)
                {
                    if(returnVal.includes('Success'))
                    {     
                        this.fetchAllContentsHpr(component,event,helper); 
                        this.showToast(component,'dismissible','Success','Updated Successfully.!!','success');
                    }
                    else {
                        this.showToast(component,'dismissible','Failed',returnVal,'error');
                    }
                    
                }
            }
            component.set("v.spinner",false);
        });
        $A.enqueueAction(action);
    },
    
      showToast : function(component, mode, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode": mode,
            "title": title,
            "message": message,
            "type": type,
            "duration":'2'
        });
        toastEvent.fire();
    },
     
})