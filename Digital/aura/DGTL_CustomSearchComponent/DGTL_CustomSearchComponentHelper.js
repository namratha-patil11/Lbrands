({
    getFilteredOptions: function(options, searchTerm) {
        searchTerm = searchTerm ? searchTerm.toUpperCase() : '';
        let filteredOptions = options.filter(function(option) {
            return option.label.toUpperCase().indexOf(searchTerm) >= 0;
        });
        return filteredOptions;
    },
    updateSelectedOption: function(component) {
        let value = component.get("v.value") || "";
        let options = component.get("v.options") || [];
        
        let selectedOption = this.getSelectedOptionForValue(options, value);
        component.set("v.selectedOption", selectedOption);
    },
    getSelectedOptionForValue: function(options, value) {
        let selectedOption = {"label": "Select an option"};
        options.forEach(function(option) {
            if(option.value === value) {
                selectedOption = option;
            }
        });
        return selectedOption;
    },
    fireOnChangeEvent : function(component, selectedOption) {
        let onchangeEvent = component.getEvent("onchange");
        let index = component.get("v.index");

        onchangeEvent.fire({
            "selectedOption": selectedOption,
            "index": index
        });
    }
})