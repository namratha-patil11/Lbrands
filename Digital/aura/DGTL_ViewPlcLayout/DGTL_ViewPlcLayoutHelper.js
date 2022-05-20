({
    initHpr : function(component,event,helper) {
        // GET logged in user brand 
        var action = component.get("c.getUserBrandHpr");
        action.setCallback(this,function(result){
            var state = result.getState();
            if(state === 'SUCCESS')
            {   
                if(result.getReturnValue() != null && result.getReturnValue() != '' && result.getReturnValue() != undefined)
                    component.set("v.selectedBrand",result.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    fetchContentJsHpr : function(component,event,searchNextBack) {
        
        if(component.get("v.selectedBrand") == '' || 
           component.get("v.selectedFloorset") == '' ||
           component.get("v.deviceType") == '' ||
           component.get("v.selectedFloorset") == null )
        {
            this.showToast(component,'dismissible','Failed','Please fill the fields - Brand , Device Type and Floorset Plan are Mandatory..!!','error');
        } else {     
            component.set("v.nextBtn",true);
            component.set("v.backBtn",true);
            component.set("v.showDateAndDownload",true);
            component.set("v.spinner",true);
            
            /*  console.log('date value before next/back---',component.get("v.dateSelect"));
            console.log('selectedBrand---',component.get("v.selectedBrand"));
            console.log('selectedPageType---',component.get("v.selectedPageType"));
            console.log('dateSelect---',component.get("v.dateSelect"));
            console.log('selectedTime---',component.get("v.selectedTime"));
            console.log('selectedFloorset---',component.get("v.selectedFloorset"));
            console.log('searchNextBack---',searchNextBack);
            console.log('snapShotDate---',component.get("v.snapShotDate"));
            console.log('deviceType---',component.get("v.deviceType")); */
            
            var action = component.get("c.fetchContentNew");
            action.setParams({'selectedBrand': component.get("v.selectedBrand"),
                              'pageType': component.get("v.selectedPageType"),
                              'dateVal': component.get("v.dateSelect"),
                              'timeVal': component.get("v.selectedTime"),
                              'floorsetId': component.get("v.selectedFloorset"),
                              'searchNextBack': searchNextBack,
                              'snapShotDate' : component.get("v.snapShotDate"),
                              'deviceType' : component.get("v.deviceType")
                             });
            action.setCallback(this,function(result){
                var state = result.getState();
                if(state === 'SUCCESS')
                {
                    component.set("v.spinner",false);
                    var returnVal = result.getReturnValue();
                    //console.log('returnVal-----'+JSON.stringify(returnVal));
                    if(returnVal !== undefined)
                    {	
                        var finalRes = returnVal;
                        component.set("v.selectedFloorset",finalRes.selectedFloorset);
                        component.set("v.placementLayoutList",finalRes.list_PlacLyt);
                        //component.set("v.placementLayoutList",finalRes.list_layoutWpr);//---testing
                        component.set("v.placementContents",finalRes.list_contentWpr);
                        component.set("v.dateSelect",finalRes.dateVal);
                        component.set("v.selectedTime",finalRes.timeVal); 
                        component.set("v.timeValStr",finalRes.timeValStr); 
                        console.log('returnVal--',returnVal);
                        var layoutList = [];
                        layoutList = component.get("v.placementLayoutList");
                        console.log('layoutList..',layoutList);
                        if(layoutList != null && layoutList != undefined && layoutList.Length != 0){
                            console.log('--- input date--',component.get("v.snapShotDate"));
                            if(component.get("v.snapShotDate") != null && component.get("v.snapShotDate") != undefined){
                                if(layoutList[0] != undefined && layoutList[0] != null){
                                    var snapshotDate = layoutList[0].Snapshot_Date__c;
                                    console.log('Selected Snapshot date--',snapshotDate);
                                    if(snapshotDate != null && snapshotDate != undefined) component.set("v.SelectedSnapShotDate",snapshotDate)
                                        }
                            }
                        }
                        
                        if(returnVal.hasContents){
                            console.log("hasContents-----",returnVal.hasContents);
                            component.set("v.hasContent",returnVal.hasContents);
                            // mapping read field api name and label
                            var custs = [];
                            var conts = finalRes.readFieldsMap;
                            for ( var key in conts ) {
                                custs.push({value:conts[key], key:key});
                            }
                            component.set("v.readFieldsList",custs);
                            
                            var contDetailFields = finalRes.cDetailsReadFieldMap;
                            var fieldsLabelValue = [];
                            for ( var key in contDetailFields ) {
                                fieldsLabelValue.push({value:contDetailFields[key], key:key});
                            }
                            component.set("v.cDetailsFields",fieldsLabelValue);
                            
                            console.log('custs--',custs);
                            component.set("v.placementLayout",finalRes.list_layoutWpr);
                            
                            //---- making collapsable section dynamic
                            if(finalRes.list_layoutWpr != null && finalRes.list_layoutWpr != undefined){
                                if(finalRes.list_layoutWpr.length == 1){
                                    component.set("v.sectionState",'open');
                                }else{
                                    component.set("v.sectionState",'close');
                                }
                                console.log('sectionState---',component.get("v.sectionState"));
                            }
                        }
                        else{
                            var message = 'No Content/Layout found for this Floorset!!'
                            this.showToast(component,'dismissible','Failed',message,'error');
                        }
                        
                        if(searchNextBack != 'Search'){
                            component.set("v.floorsetPlanList",finalRes.list_PlacLytFloorset);
                        }                    
                        if(finalRes.errorStatus != ''){
                            this.showToast(component,'dismissible','Failed',finalRes.errorStatus,'error');
                        }
                        component.set("v.spinner",false);
                    }
                    else
                    {
                        this.showToast(component,'dismissible','Failed','Some Error.!!','error');
                    }
                }else{ 
                    component.set("v.spinner",false);
                    var errors = result.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            }); 
            $A.enqueueAction(action);
        }
    }, 
    
    validateFloorsetBrand : function(component, event){
        component.set("v.spinner",true);
        var action = component.get("c.getFloorsetName");
        action.setParams({'floorsetId': component.get("v.selectedFloorset")});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){   
                let floorsetName = response.getReturnValue();
                let selectedBrand = component.get("v.selectedBrand");
                if(!floorsetName.startsWith(selectedBrand)){
                    this.showToast(component,'dismissible','Error','Please select valid floorset as per the selected brand.','error');
                    component.set("v.selectedFloorset",null);
                }
                component.set("v.spinner",false);
            }
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