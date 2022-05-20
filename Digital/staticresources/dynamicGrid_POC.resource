window.loadDynamicGrid = function (component, isGridViewShown) {
    console.log("loadDynamicGrid");

    function getFilteredData(componentData) {
        return componentData.filter(function (data) {
            const type = data.pContentRec.Type__c;
            const active = data.pContentRec.Active__c;
            return type == "Controlled" && active;
        });
    }

    var contentData = getFilteredData(component.get("v.placementContents"));
    console.log(contentData);

    function printList() {
        for (let i = 0; i < contentData.length; i++) {
            console.log(contentData[i]);
        }
    }
    var lookForListView = null;

    function loadListView() {
        clearInterval(lookForListView);
        $("#grid-control-view").remove();
        $("#grid-view-container").remove();
        console.log($(".slds-has-dividers_around-space > li").length);

        $.fn.extend({
            buildGridView: function () {
                let $listContainer = $(this);
                let $originalListContainer = $(".slds-has-dividers_around-space > li");
                let $articleContainer;
                const $layoutView = $(`<ul class="grid-view-container" id="grid-view-container"/>`);
                const $controlView = $(`<div id="grid-control-view"/>`);
                const $selectDragOptions = $(`<select class="drag-option" value="">
                  <option value="" selected="selected">None</option>
                  <option value="row">Row</option>
                  <option value="column">Column</option>
                  <option value="sub-row">Sub Row</option>
                </select>`);
                const $updateGridBtn = $(`<button id="ss_update_grid_btn">Update Grid</button>`)
                const $toggleOriginalView = $(`<span class="toggle-grid-view-btn">Grid View<input type="checkbox" id="toggle-original-view"/><label for="toggle-original-view"></label></span>`);
                let $activeDraggableItem = null;
                let $gridListView;
                let $closeBtn;
                let selectedListItemId = false;

                $listContainer.append($layoutView);
                $controlView.append($selectDragOptions);
                $controlView.append($updateGridBtn);
                $controlView.append($toggleOriginalView);
                $layoutView.before($controlView);

                const $toggleGridview = $("#toggle-original-view");



                function refreshListItems() {
                    if ($listContainer.find(">div").length) {
                        return $listContainer.find(">div>li");
                    }
                    return $listContainer.find(">li");
                }

                function sortContentData() {
                    return contentData.sort((a, b) => (a.pContentRec.S_No__c > b.pContentRec.S_No__c) ? 1 : -1);
                }

                function _triggerSortableforOriginalItems() {
                    /*
                    var count = 0;
                    $layoutView.find("li.view-box").each(function (e) {
                        const itemIndex = parseInt($(this).attr("id").match(/\d+/)[0]);
                        $listContainer.append($listItems[itemIndex]);
                        component.set(`v.placementContents.${itemIndex}.pContentRec.S_No__c`, count);
                        count++;

                    });
                    contentData = sortContentData(getFilteredData(component.get("v.placementContents")));

                    $listItems = refreshListItems();
                    */
                }

                function _hideAllItems() {
                    $(selectedListItemId).removeClass("display_row").hide();
                    $originalListContainer.hide();
                    $gridListView.removeClass("active-item");
                    selectedListItemId = false;
                }

                function enableCloseBtnEvent() {
                    $closeBtn.on("click", function (e) {
                        e.preventDefault();

                        const $self = $(this);
                        $(selectedListItemId).removeClass("display_row").hide();
                        $self.closest("li.view-box").removeClass("active-item");
                        selectedListItemId = false;
                        return false;
                    });
                }

                function _enableSortable() {
                    if ($activeDraggableItem) {
                        $activeDraggableItem.sortable({
                            opacity: 0.7,
                            update: _triggerSortableforOriginalItems
                        });
                    }
                }

                function _disableSortable() {
                    if ($activeDraggableItem) {
                        $activeDraggableItem.sortable("destroy");
                    }
                }

                function _loadGridLayout() {
                    //printList();
                    function _getListLayout() {
                        const listLayout = [];
                        let subListLayout = [];
                        let columns = 0;
                        let isGroupStarted = false;
                        let inValid = 0;

                        function addList(isRowStart) {
                            if (isRowStart && subListLayout.length) {
                                listLayout.push(subListLayout);
                                columns = 0;
                                subListLayout = [];
                            }
                        }

                        contentData.forEach(function (data) {
                            const isRowStart = data.pContentRec.Row_Start__c;
                            const groupStatus = data.pContentRec.Grouped__c;

                            if (groupStatus === "Group Start") {
                                isGroupStarted = true;
                                inValid++;
                            }

                            if (groupStatus === "Group End") {
                                isGroupStarted = false;
                                inValid--;
                            }

                            addList(isRowStart);

                            if (isGroupStarted) {
                                columns++;
                            } else {
                                if (columns) {
                                    columns++;
                                    subListLayout.push(columns);
                                    columns = 0
                                } else {
                                    subListLayout.push(1);
                                }
                            }
                        });

                        addList(true);

                        if (inValid) {
                            alert("Group not closed properly.");
                            return false;
                        }

                        return listLayout;
                    }

                    function _resetGridLayout() {
                        let listIndex = 0;
                        let rowCount = 0;
                        const listLayout = _getListLayout();
                        if (!listLayout) {
                            return;
                        }
                        $layoutView.html("");
                        if (isGridViewShown) {
                            $originalListContainer.hide();
                        } else {
                            $layoutView.hide();
                            $selectDragOptions.hide();
                            $updateGridBtn.hide();
                            isGridViewShown = true;
                        }

                        if (selectedListItemId) {
                            $(selectedListItemId).show();
                        }

                        listLayout.forEach(function (row) {
                            const column = row.length;
                            let $main = $(`<li class="flex-box"/>`);
                            for (let i = 0; i < column; i++) {
                                let $group = $(`<ul class="inline" style="width: ${100/column}%"/>`);
                                for (let item = 0; item < row[i]; item++) {
                                    let $newItem = $(`<li class="view-box" id="list_id_${listIndex}" data-id="${contentData[listIndex].conId}">${contentData[listIndex].pContentRec.Main_Message__c}<a class="close-btn">&#10005;</a></li>`);
                                    $($group).append($newItem);
                                    listIndex++;
                                }
                                $main.append($group);
                            }
                            $layoutView.append($main);
                        });

                        $gridListView = $layoutView.find("li.view-box");
                        $closeBtn = $gridListView.find(".close-btn");
                        enableCloseBtnEvent();
                    }
                    _resetGridLayout();
                }

                function _loadGridEvents() {
                    $layoutView.on("click", "li.view-box", function () {
                        const $selectedComponent = $(this);
                        const $selectorWrapper = $selectedComponent.closest(".inline");
                        const diff = $selectedComponent.outerHeight(true) - $selectedComponent.outerHeight();
                        const top = $selectedComponent.offset().top + $selectedComponent.outerHeight(true) - (diff + 103);
                        const itemId = `#${$selectedComponent.data("id")}`;

                        _hideAllItems();
                        $selectedComponent.addClass("active-item");
                        $(itemId).addClass("display_row").css({
                            top: `${top}px`
                        }).show();
                        $selectedComponent.find(".close-btn").show();
                        selectedListItemId = itemId;
                    });

                    $listContainer.on("change", "input[name='Grouped__c']", function () {

                        if ($(this).val() === "Group End") {
                            _loadGridLayout();
                        }
                    });



                    $listContainer.find("lightning-input-field").on('click', "[name='Row_Start__c'] + label", function () {

                        _loadGridLayout();
                    });

                    $toggleGridview.on('change', function () {
                        if(!$originalListContainer.length) {
                            contentData = getFilteredData(component.get("v.placementContents"));
                            $originalListContainer = $(".slds-has-dividers_around-space > li");
                            _loadGridLayout();
                            $originalListContainer.show();
                        }

                        $originalListContainer.toggle();
                        $layoutView.toggle();
                        $selectDragOptions.toggle();
                        $updateGridBtn.toggle();
                        $articleContainer.toggle();
                    });

                    $updateGridBtn.on('click', function () {
                        contentData = getFilteredData(component.get("v.placementContents"));
                        // $listItems = refreshListItems();
                        _hideAllItems();
                        _loadGridLayout();
                    });

                    $selectDragOptions.on('change', function () {
                        const option = $(this).val();
                        _disableSortable();

                        if (option == "row") {
                            $activeDraggableItem = $(".grid-view-container");
                        } else if (option == "column") {
                            $activeDraggableItem = $(".grid-view-container > li");
                        } else if (option == "sub-row") {
                            $activeDraggableItem = $(".grid-view-container > li  > ul");
                        } else {
                            $activeDraggableItem = null;
                        }

                        _enableSortable();
                    });

                    function updateViewChangeEvents() {

                        $articleContainer = $("#grid-view-container + article");
                        const mainContainer = document.querySelector(".slds-has-dividers_around-space");
                        if (mainContainer.addEventListener) {
                             mainContainer.addEventListener ('DOMNodeInserted', OnNodeInserted, false);
                             mainContainer.addEventListener ('DOMNodeInsertedIntoDocument', OnNodeInsertedIntoDocument, false);
                             mainContainer.addEventListener ('DOMNodeRemoved', OnNodeRemoved, false);
                            mainContainer.addEventListener('DOMNodeRemovedFromDocument', OnNodeRemovedFromDocument, false);
                        }

                        component.set("v.spinner", false);
                    }
                    //updateViewChangeEvents();

                    function OnNodeInserted() {
                        console.log("%cOnNodeInserted", "color: #00ffff");
                    }

                    function OnNodeInsertedIntoDocument() {
                        console.log("%OnNodeInsertedIntoDocument", "color: #00ff00");
                    }

                    function OnNodeRemoved() {
                        console.log("%cOnNodeRemoved", "color: #ff0000");
                    }

                    function OnNodeRemovedFromDocument() {
                        component.set("v.spinner", true);
                        console.log("%cOnNodeRemovedFromDocument", "color: #0000ff");
                        $selectDragOptions.hide();
                        $updateGridBtn.hide();
                        $layoutView.hide();
                        $(".view-box.active-item").removeClass("active-item");
                        selectedListItemId = false;
                        if ($toggleGridview.is(":checked")) $toggleGridview.prop('checked', false);
                        setTimeout(function () {
                            $listContainer = $(".slds-has-dividers_around-space");
                            // $listItems = refreshListItems();
                            updateViewChangeEvents();
                        }, 10);
                    }
                }
                //_loadGridLayout();
                _loadGridEvents();

            }
        });

        $("#dynamicGrid").buildGridView();
    }
    loadListView();
}