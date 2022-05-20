#dynamicGrid > li {
    background: #fff;
}

#dynamicGrid {
    display: flex;
	flex-direction: column;
}

#dynamicGrid .slds-has-dividers_around-space {
    order: 2;
}

#dynamicGrid .slds-has-dividers_around-space > div > li.display_row {
    background: #ffffff;
    padding: 10px;
}

#dynamicGrid .close-btn {
    display: none; 
    position: relative;
    padding: 10px 14px;
    height: 40px;
    border: 1px solid;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.5);
    text-decoration: none;
    z-index: 5;
}

#dynamicGrid .close-btn:hover {
    font-weight: bold;
    box-shadow: 0 0 5px #aaa;
}

#dynamicGrid .grid-view-container li {
    min-height: 100px;
    margin: 19px 21px;
    padding: 10px;
    border: 1px solid #aaa;
    box-sizing: border-box;
}

#dynamicGrid > .grid-view-container,
#dynamicGrid > .grid-view-container > li {
    margin: 0;
    padding: 0;
    border: 0;
}

.slds-has-dividers_around-space > li {
    background: #ffffff;
}

#dynamicGrid > .grid-view-container > li > ul {
    margin-right: 5px;
}

#dynamicGrid > .grid-view-container > li li {
    display: flex;
    flex: 1;
    margin: 5px 0;
    justify-content: space-between;
    flex-flow: wrap;
    border-radius: 5px;
    box-shadow: inset 0 0 5px #aaa;
}

#dynamicGrid > .grid-view-container > li li:hover {
    background: #eee;
    box-shadow: 0 0 3px rgba(0, 0, 0, 0.5);
}

#dynamicGrid .flex-box {
    display: flex;
}

#dynamicGrid .inline {
    display: flex;
    flex-direction: column;
}

#dynamicGrid .flex-box .inline li:only-child {
    height: calc(100% - 10px);
}

#dynamicGrid .flex-box .inline .view-box.active-item {
    box-shadow: none;
    position: relative;
    z-index: 4;
    background: #fff;
    border: 1px solid #777;
    border-bottom: 0;
    border-radius: 5px 5px 0 0;
}

#dynamicGrid .flex-box .inline .view-box.active-item .close-btn {
    display: inline;
}

#dynamicGrid li.display_row,
.slds-has-dividers_around-space li.display_row {
   	position: absolute;
    width: calc(100% - 23px);
    z-index: 3;
    left: calc(50% - 3px);
    margin: 0 auto 30px !important;
    transform: translateX(-50%);
    border: 1px solid #777;
    border-radius: 0 0 0.25rem 0.25rem;
}

#grid-control-view {
    display: flex;
    justify-content: flex-end;
    position: relative;
    padding: 5px;
    margin-top: 5px;
}

#grid-control-view .toggle-grid-view-btn {
    font-size: 13px;
    font-weight: bold;
    color: #1b5297;
}

.drag-option,
#ss_update_grid_btn {
    margin-right: 20px;
}

#toggle-original-view {
    display: none;
}

#toggle-original-view + label {
    position: relative;
    display: inline-block;
    width: 40px;
    margin: 0 46px 0 5px;
    border-radius: 3px;
    border-bottom: 6px solid #aaa;
}

#toggle-original-view + label:before {
    content: ' ';
    display: inline-block;
    width: 20px;
    height: 20px;
    border-radius: 50%;
    background: #aaa;
    position: absolute;
    top: -7px;
} 

#toggle-original-view + label:after {
    content: 'OFF';
    width: 30px;
    color: #fff;
    display: inline-block;
    position: absolute;
    background: #aaa;
    padding: 3px;
    right: -40px;
    top: -7px;
    font-size: 13px;
    text-align: center;
    border-radius: 3px;
}

#toggle-original-view:checked + label {
    border-bottom: 6px solid #4f84d4;
    box-shadow: 0 0 3px #aaa;
}

#toggle-original-view:checked + label:before {
    background: #4f84d4;
    right: 0;
    box-shadow: 0 0 3px #aaa;
}

#toggle-original-view:checked + label:after {
    content: 'ON';
    background: #4f84d4;
    box-shadow: 0 0 3px #aaa;
}

.cDGTL_MainCmpNew tr.tableTRTHCurve:last-child td {
    border-bottom: 0;
}

.cDGTL_MainCmpNew .tableTRTHCurve:last-child {
    border-right: 0;
}


