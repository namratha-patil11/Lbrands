import { LightningElement, api, track } from 'lwc';

export default class SortableContainer extends LightningElement {
	@api items = [];
    @api dynamicInputArray = {nameFields:[],name:'',swapIndexField:[],isLayout:false}; // provide either one (name or nameField), swapIndexField is optional
	@api detailitems = [];
	@track header;

	@track
	_sortedList = [];

	@api selecteditems = [];
	@track filtereditems = [];

	@api get sortedList () {
		return this._sortedList;
	}

	splitDataforContent(){
		let items = [];
		let index = 0;
		this.items.forEach(element => {
			let cont = Object.assign({}, JSON.parse(JSON.stringify(element)));
			if(cont.pContentRec && cont.pContentRec.Type__c 
				&& cont.pContentRec.Type__c == 'Controlled' && cont.pContentRec.Active__c === true)
			{
				index = index + 1;
				cont.pContentRec.S_No__c = index;
				this.selecteditems.push(cont);
			}else{
				items.push(cont);
			}
			
		});
		this.filtereditems  = items;
		//console.log('this.filtereditems----'+JSON.stringify(this.filtereditems));
		//console.log('this.selecteditems-----'+JSON.stringify(this.selecteditems));
	}

	splitDataforContentDetails(){
		let items = [];
		let index = 0;
		this.detailitems.forEach(element => {
			let cont = Object.assign({}, JSON.parse(JSON.stringify(element)));
			index = index + 1;
			cont.S_No__c = index;
			this.selecteditems.push(cont);
		});
		//console.log('this.filtereditems----'+JSON.stringify(this.filtereditems));
		console.log('this.selecteditems-----'+JSON.stringify(this.selecteditems));
	}


	set sortedList (value) {		
		this._sortedList = [];
		value.forEach(element => {
			this._sortedList.push(element);
		});
	}

	connectedCallback() {
		this.items.forEach( element => this._sortedList.push(element));
		if(this.dynamicInputArray.isLayout){
			this.header = 'Reorder - Placement Content';
			this.splitDataforContent();
		}else{
			this.header = 'Reorder - Placement Content Detail';
			this.splitDataforContentDetails();
		}
	}

	handleListChanged(ev) {
		this.sortedList = ev.target.items;
		// eslint-disable-next-line no-console
		console.log('this.sortedList----'+JSON.stringify(ev.target.items));
	}

	closeModal(){
        const closeModalEvt = new CustomEvent('closeSortable');
        this.dispatchEvent(closeModalEvt);
	}
	
	saveChanges(){
		if(this.dynamicInputArray.isLayout) {
			this.getActualSortedList();
		}else{
			this.getSortedListForDetail();
		}
		console.log('inside save--');
		const value = this.sortedList;
        const sortSaveEvt = new CustomEvent('sortNow',{
			detail : {value}
		});
        this.dispatchEvent(sortSaveEvt);
		
	}

	getSortedListForDetail(){
		let sortedListItems = [];
		this.items.forEach(element => {
			let cont = Object.assign({}, JSON.parse(JSON.stringify(element)));
			if(cont.pContentRec.Id == this.sortedList[0].Placement_Content__c){
				cont.ContentDetWpr.detailList = this.sortedList;	
			}
			sortedListItems.push(cont);
		});
		this.sortedList = sortedListItems;
	}

	getActualSortedList(){
		let sortedListItems = [];
		let deleteditems = [];
		this.sortedList.forEach(element => {
			let cont = Object.assign({}, element);
			sortedListItems.push(cont);
			this.filtereditems.forEach(filterelement => {
				let filtercont = Object.assign({}, filterelement);
				if(filtercont.pContentRec.Active__c == true){
					if(filtercont.pContentRec.Parent_Content__c && filtercont.pContentRec.Parent_Content__c == cont.pContentRec.Id){
						filtercont.pContentRec.S_No__c = cont.pContentRec.S_No__c;
						sortedListItems.push(filtercont);
					}
				}/*else if(filtercont.pContentRec.S_No__c == cont.pContentRec.S_No__c){
						sortedListItems.push(filtercont);
				}*/
			});
		});

		this.filtereditems.forEach(filterelement => {
			if(!filterelement.pContentRec.Active__c){
				deleteditems.push(filterelement);
			}
		});

		/*if(deleteditems && deleteditems.length > 0){
			sortedListItems.forEach(element => {
				deleteditems = deleteditems.filter((item) => item.pContentRec.Id != element.pContentRec.Id);
			});
		}*/
		sortedListItems = sortedListItems.concat(deleteditems);
		this.sortedList = sortedListItems;
		//console.log('sortedList-----'+JSON.stringify(this.sortedList));
	}

}