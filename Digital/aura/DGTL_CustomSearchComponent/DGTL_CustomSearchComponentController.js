({
    doInit : function(component, event, helper) {
		let options = component.get("v.options") || [];
        let filteredOptions = JSON.parse(JSON.stringify(options));
        
        component.set("v.filteredOptions", filteredOptions);
        helper.updateSelectedOption(component);
    },
    valueChangeHandler : function(component, event, helper) {
        helper.updateSelectedOption(component);
    },
    handleOnclick : function(component, event, helper) {
        let disabled = component.get("v.disabled");
        
        if(disabled) {
            return;
        }
        
        let searchActive = component.get("v.searchActive");
		component.set("v.searchActive", !searchActive);
        if(searchActive) {
            component.find("inputField").getElement().focus();   
        }
    },
    handleOnkeyup : function(component, event, helper) {
		let searchTerm = component.find("inputField").getElement().value;
        let options = component.get("v.options") || [];
        
        let filteredOptions = helper.getFilteredOptions(options, searchTerm);
        
        component.set("v.filteredOptions", filteredOptions);
        component.set("v.searchTerm", searchTerm);
    },
    selectHandler : function(component, event, helper) {
		let selectedValueIndex = Number(event.currentTarget.id || event.target.id);
        let filteredOptions = component.get("v.filteredOptions") || [];
        let selectedOption = filteredOptions[selectedValueIndex] || {};
        
        component.set("v.selectedOption", selectedOption);
        component.set("v.value", selectedOption.value);
		component.set("v.searchActive", false);
        
        helper.fireOnChangeEvent(component, selectedOption);
    },
    showError: function(component, event, helper) {
        let params = event.getParam("arguments");
            
        component.set("v.error", true);
        component.set("v.errorMessage", params["errorMessage"]);
    },
    hideError: function(component, event, helper) {
        component.set("v.error", false);        
    }
})