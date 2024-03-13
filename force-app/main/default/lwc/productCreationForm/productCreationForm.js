import { LightningElement, api, wire, track } from "lwc";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import getFilteredProducts from "@salesforce/apex/productFilterController.getFilteredProducts";
import createProductParts from "@salesforce/apex/productFilterController.createProductParts";
import getInsertedProductParts from "@salesforce/apex/productFilterController.getInsertedProductParts";
import UpdateProductParts from "@salesforce/apex/productFilterController.UpdateProductParts";
import handleAfterInsert from "@salesforce/apex/productFilterController.handleAfterInsert";
import deleteProductPart from "@salesforce/apex/productFilterController.deleteProductPart";
  import { ShowToastEvent } from "lightning/platformShowToastEvent";

// import FILTERS_UPDATED_MESSAGE from '@salesforce/messageChannel/FiltersUpdated__c';
import ProductName_FIELD from "@salesforce/schema/Product2.Name";
import ConsumerGoodsProductCode_FIELD from "@salesforce/schema/Product2.cgcloud__Consumer_Goods_Product_Code__c";
import Description1Language1_FIELD from "@salesforce/schema/Product2.cgcloud__Description_1_Language_1__c";
import ProductTemplate_FIELD from "@salesforce/schema/Product2.cgcloud__Product_Template__c";
import ProductBundle_FIELD from "@salesforce/schema/Product2.Product_Bundle__c";
import UnitNotes_FIELD from "@salesforce/schema/Product2.Unit_Notes__c";
import ITEMCATEGORY_FIELD from "@salesforce/schema/Product2.Item_Category__c";
import BRAND_FIELD from "@salesforce/schema/Product2.Brands__c";
import POLES_FIELD from "@salesforce/schema/Product2.Poles__c";
import CURRENT_FIELD from "@salesforce/schema/Product2.Current__c";

import PRODUCT_OBJECT from "@salesforce/schema/Product2";
import { CurrentPageReference } from "lightning/navigation";

import { refreshApex } from '@salesforce/apex';

const columns = [{ label: "Product Name", fieldName: "Name", type: "text" }];

const Addcolumns = [
  //  { label: 'Product Name', fieldName: 'productBundlePartName', type: 'text' },
  {
    label: "Part Description",
    fieldName: "PartDescription",
    type: "text",
    editable: true,
  },
 
  //  { label: 'Dimension', fieldName: 'dimension', type: 'text', editable:true},
  { label: "Quantity", fieldName: "quantity", type: "number", editable: true },
  { label: "List Price", fieldName: "listprice", type: "currency" },
  {
    label: "Price Factor",
    fieldName: "pricefactor",
    type: "number",
    editable: true,
    typeAttributes: {
      minimumFractionDigits: 1,
      maximumFractionDigits: 1,
    },
  },
  {
    type: 'button-icon',
    typeAttributes: {
        iconName: 'utility:delete',
        name: 'delete',
        title: 'Delete',
        variant: 'bare',
        alternativeText: 'Delete'
    }
}
];

const NONE_OPTION = { label: "None", value: "" };

export default class productCreationForm extends LightningElement {
  @wire(CurrentPageReference)
  pageRefData;


  selectedprodRows = [];
  products = [];
  Addedproducts = [];
  insertedproductparts = [];
  productBundlePartsData = [];
  updatedvalues = "";
  updatevalue = "";
  updatedval = "";
  updatedCurrent = "";
  error;
  draftValues;

  refreshTableResult;


  @api recordId;
  // for the inserted parts

  // this is for - after click on nect button
  @track selectedProducts = [];
  @track reocrdurl;
  @track opportunityRecordId;
  @track localStorageId;
  @track refreshedOppId;
  @track refUrl;
  connectedCallback() {
      this.opportunityRecordId = this.pageRefData.attributes.recordId;
      this.reocrdurl = this.pageRefData.attributes.url;
      console.log('return url',this.reocrdurl);

      // localStorage.setItem("refreshedID", this.opportunityRecordId);
      if(localStorage.getItem("refreshedID")){
        this.opportunityRecordId = localStorage.getItem("refreshedID");
        console.log('refreshed id ---->',this.opportunityRecordId )
      }

      if(localStorage.getItem("refreshedUrl")){
        this.reocrdurl = localStorage.getItem("refreshedUrl");
        console.log('refreshed  url id ---->',this.reocrdurl )
      }

      this.refreshedOppId = this.opportunityRecordId;
      this.refUrl = this.reocrdurl;
    localStorage.clear();

  }



  handleRefresh() {
    localStorage.setItem("refreshedID", this.opportunityRecordId);
    console.log('local ID:',localStorage.getItem("refreshedID"));

    localStorage.setItem("refreshedUrl", this.reocrdurl);
    console.log('local ID:',localStorage.getItem("refreshedUrl"));

    window.location.reload();
  }

  handlecancel(){
  //  localStorage.setItem("refreshedUrl", this.reocrdurl);
  //  console.log('local ID:',localStorage.getItem("refreshedUrl"));
    window.location.href=this.reocrdurl;
    
  }

  handleRowSelection(event) {
    const selectedRows = event.detail.selectedRows;
    this.selectedProducts = selectedRows;
  }

  // connectedCallback() {
  //     const urlParams = new URLSearchParams(window.location.search);
  //     this.recordId = urlParams.get('recordId');

  //     if (this.recordId) {
  //         console.log('Record ID:', this.recordId);
  //         this.sendDrawings();
  //     } else {
  //         console.error('Record ID not found in the URL');
  //     }
  // }

  objectName = PRODUCT_OBJECT;
  recordTypeId = "0121m000001gaKoAAI";
  createdRecordId;

  items = [];
  sheets = [];
  categories = [];
  widths = [];

  Recordtype;

  objectFields = [
    ProductName_FIELD,
    ConsumerGoodsProductCode_FIELD,
    ProductTemplate_FIELD,
    Description1Language1_FIELD,
    ProductBundle_FIELD,
    UnitNotes_FIELD,
  ];

  handleCancel(event) {
    console.log(event.type);
    console.log(JSON.stringify(event.detail));
  }

  handleSuccess(event) {
    // Capture the ID of the created record
    this.createdRecordId = event.detail.id;
    console.log("Record created with ID:", this.createdRecordId);

    this.handleinsidemwthod();
  }

  // insert the product as opportunity line item to the given opportunity
  handleinsidemwthod() {
    handleAfterInsert({
      parentId: this.createdRecordId,
      opportunityRecordId: this.opportunityRecordId || this.refreshedOppId,
    })
      .then((result) => {
        console.log(" result -----> " + result);
      })
      .catch((error) => {
        this.error = error;
      });
  }

  /*objectInfo*/

  @wire(getObjectInfo, { objectApiName: PRODUCT_OBJECT })
  objectInfo({ data, error }) {
    if (data) {
      const rtis = data.recordTypeInfos;

      this.Recordtype = data.defaultRecordTypeId; //  console.log('sample------------>' + this.Recordtype);
    }

    if (error) {
      console.log("error" + error);
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: "$Recordtype",

    fieldApiName: ITEMCATEGORY_FIELD,
  })
  wiredItems({ data, error }) {
    //console.log('datacountries1' + JSON.stringify(data));
    if (data) {
      if (data.values) {
        this.items = [
          NONE_OPTION,
          ...data.values.map((itemss) => ({
            label: itemss.label,
            value: itemss.value,
          })),
        ]; //  console.log('datacountries', this.items);
      } else {
        console.error(
          "Picklist values are undefined or not in the expected structure."
        );
      }
    } else if (error) {
      console.error("Error fetching picklist values", error);
    }
  }
  handleChange(event) {
    this.updatedvalues = event.target.value;
    console.log("Selected Item Type:", this.updatedvalues);
  }

  @wire(getPicklistValues, {
    recordTypeId: "$Recordtype",

    fieldApiName: BRAND_FIELD,
  })
  wirecategoriess({ data, error }) {
    //   console.log('datacountries1' + JSON.stringify(data));
    if (data) {
      if (data.values) {
        this.sheets = [
          NONE_OPTION,
          ...data.values.map((itememe) => ({
            label: itememe.label,
            value: itememe.value,
          })),
        ]; //   console.log('datacountries', this.sheets);
      } else {
        console.error(
          "Picklist values are undefined or not in the expected structure."
        );
      }
    } else if (error) {
      console.error("Error fetching picklist values", error);
    }
  }
  handle(event) {
    this.updatedval = event.detail.value;
    console.log("Selected Brand:", this.updatedval);
  }

  @wire(getPicklistValues, {
    recordTypeId: "$Recordtype",

    fieldApiName: POLES_FIELD,
  })
  wiredSheets({ data, error }) {
    //   console.log('datacountries1' + JSON.stringify(data));
    if (data) {
      if (data.values) {
        this.categories = [
          NONE_OPTION,
          ...data.values.map((item) => ({
            label: item.label,
            value: item.value,
          })),
        ]; //     console.log('datacountries', this.categories);
      } else {
        console.error(
          "Picklist values are undefined or not in the expected structure."
        );
      }
    } else if (error) {
      console.error("Error fetching picklist values", error);
    }
  }
  handleCha(event) {
    this.updatevalue = event.detail.value;
    console.log("Selected Pole:", this.updatevalue);
  }

  @wire(getPicklistValues, {
    recordTypeId: "$Recordtype",

    fieldApiName: CURRENT_FIELD,
  })
  wiredwidths({ data, error }) {
    //   console.log('Current --> ' + JSON.stringify(data));
    if (data) {
      if (data.values) {
        this.widths = [
          NONE_OPTION,
          ...data.values.map((iteme) => ({
            label: iteme.label,
            value: iteme.value,
          })),
        ]; //    console.log('Get Current --> ', this.widths);
      } else {
        console.error(
          "Picklist values are undefined or not in the expected structure."
        );
      }
    } else if (error) {
      console.error("Error fetching picklist values", error);
    }
  }

  handlewidth(event) {
    this.updatedCurrent = event.detail.value;
    console.log("Selected Current:", this.updatedCurrent);
  }

  @wire(getFilteredProducts, {
    itemType: "$itemType",
    brand: "$brand",
    pole: "$pole",
    current: "$current",
  })
  wiredProd({ error, data }) {
    if (data) {
      this.products = data;
    } else if (error) {
      // Handle error
      console.error(error);
    }
  }

  isProduct = false;
  handleSearch() {
    getFilteredProducts({
      itemType: this.updatedvalues,
      brand: this.updatedval,
      pole: this.updatevalue,
      current: this.updatedCurrent,
    })
      .then((result) => {
        this.isProduct = true;
        this.products = result;
        this.error = undefined;
        console.log("the result is = " + this.products);
        console.log(JSON.stringify(this.products));
      })
      .catch((error) => {
        this.error = error;
        this.products = [];
        console.log("error = " + JSON.stringify(error));
      });
  }

  isdraftValues = false;
  
  // logic on the nect button click
  handleNext() {
    this.draftValues = true; 
    if (this.selectedProducts.length === 0) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: "Error",
                message: "Please select at least one product.",
                variant: "error",
            })
        );
        return;
    }

    createProductParts({
      parentId: this.createdRecordId,
      selectedProducts: this.selectedProducts,
    })
      .then((result) => {
        // Handle success, if needed
        console.log(result);
        console.log(JSON.stringify(result));
        this.handleInserted();
      })
      .catch((error) => {
        // Handle error, if needed
        console.error(error);
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: "Error creating Product Parts.",
            variant: "error",
          })
        );
      });
  }

  handleInserted() {
    getInsertedProductParts({ parentId: this.createdRecordId })
      .then((result) => {
        console.log("product bundle Ids fetching ---->");
        console.log(
          "Products parts coming from apex---->",
          JSON.stringify(result)
        );

        this.productBundlePartsData = result?.map((item, ind) => ({
          Id: item.Id,
          productBundlePartName: item.Name,
          PartDescription: item.Part_Description__c,
          dimension: item.Dimensions__c,
          quantity: item.cgcloud__Quantity__c,
          pricefactor: item.Price_factor__c,
          listprice: item.List_price__c,
        }));
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Product Parts created successfully.",
            variant: "success",
          })
        );
      })
      .catch((error) => {
        // Handle error, if needed
        console.error(error);
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: "Error creating Product Parts.",
            variant: "error",
          })
        );
      });
  }
  // handle save on editing of table

  handleSave(event) {
    console.log("save event invoking");
    console.log("productbundledata---->", this.productBundlePartsData);
    this.draftValues = event.detail.draftValues;
    console.log("edited cell draftvalues found------>", this.draftValues);
    this.productBundlePartsData = this.productBundlePartsData.map(
      (PartiIem) => {
        const matchingDraftValue = this.draftValues.find(
          (draftItem) => draftItem.Id === PartiIem.Id
        );

        if (
          matchingDraftValue &&
          matchingDraftValue.dimension !== PartiIem.dimension
        ) {
          PartiIem.dimension = matchingDraftValue.dimension
            ? matchingDraftValue.dimension
            : PartiIem.dimension;
          console.log("Updated dimension:", PartiIem.dimension);
        }
        if (
          matchingDraftValue &&
          matchingDraftValue.PartDescription !== PartiIem.PartDescription
        ) {
          PartiIem.PartDescription = matchingDraftValue.PartDescription
            ? matchingDraftValue.PartDescription
            : PartiIem.PartDescription;
          console.log("Updated PartDescription:", PartiIem.PartDescription);
        }
        if (
          matchingDraftValue &&
          matchingDraftValue.quantity !== PartiIem.quantity
        ) {
          PartiIem.quantity = matchingDraftValue.quantity
            ? matchingDraftValue.quantity
            : PartiIem.quantity;
          console.log("Updated quantity:", PartiIem.quantity);
        }
        if (
          matchingDraftValue &&
          matchingDraftValue.pricefactor !== PartiIem.pricefactor
        ) {
          PartiIem.pricefactor = matchingDraftValue.pricefactor
            ? matchingDraftValue.pricefactor
            : PartiIem.pricefactor;
          console.log("Updated pricefactor:", PartiIem.pricefactor);
        }
        if (
          matchingDraftValue &&
          matchingDraftValue.listprice !== PartiIem.listprice
        ) {
          PartiIem.listprice = matchingDraftValue.listprice
            ? matchingDraftValue.listprice
            : PartiIem.listprice;
          console.log("Updated listprice:", PartiIem.listprice);
        }
        return PartiIem;
      }
    );
    console.log(
      "updated selected products parts data----->",
      this.productBundlePartsData
    );
    this.UpdateParts();
  }

  // handleSave(event) {
  //     console.log("save event invoking");
  //     this.draftValues = event.detail.draftValues;
  //     console.log("edited cell draftvalues found------>", this.draftValues);
  //     this.productBundlePartsData = this.productBundlePartsData.map(
  //       (PartiIem) => {
  //         const matchingDraftValue = this.draftValues.find(
  //             (draftItem) => draftItem.Id === PartiIem.Id
  //           );
  //           if (
  //             matchingDraftValue &&
  //             matchingDraftValue.Dimensions__c !== PartiIem.Dimensions__c
  //           ) {
  //             PartiIem.Dimensions__c = matchingDraftValue.Dimensions__c
  //               ? matchingDraftValue.Dimensions__c
  //               : PartiIem.Dimensions__c;
  //             console.log("Updated dimension:", PartiIem.Dimensions__c);
  //           }
  //           if (
  //             matchingDraftValue &&
  //             matchingDraftValue.Part_Description__c !== PartiIem.Part_Description__c
  //           ) {
  //             PartiIem.Part_Description__c = matchingDraftValue.Part_Description__c
  //               ? matchingDraftValue.Part_Description__c
  //               : PartiIem.Part_Description__c;
  //             console.log("Updated Part_Description__c:", PartiIem.Part_Description__c);
  //           }
  //         return PartiIem;
  //       }
  //     );
  //     console.log(
  //       "updated selected products parts data----->",
  //       this.productBundlePartsData
  //     );
  //     this.UpdateParts();
  //   }

  //   update table logic
  UpdateParts() {
    console.log(
      "selected data parts for create method---->",
      this.productBundlePartsData
    );
    console.log("new array data--->");
    UpdateProductParts({
      parentId: this.createdRecordId,
      insertedProducts: this.productBundlePartsData,
    })
      .then((result) => {
        console.log("newly created products ------>", result);
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Product Parts created successfully.",
            variant: "success",
          })
        );
      })
      .catch((error) => {
        console.error(error);
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: "Error creating Product Parts.",
            variant: "error",
          })
        );
      });
  }






  handleRowAction(event) {
    const action = event.detail.action;
    console.log("Row ID--->" + JSON.stringify(event.detail));

    const row = event.detail.row.Id;
    console.log("Row ID--->" + row);

    switch (action.name) {
        case "delete":
            this.handleDelete(row);
            break;
        // Handle other actions if needed
    }
}






    // Method to handle the delete button click
    handleDelete(event) {
      const productId = event.detail.row.Id;
      console.log("Product ID ID--->" + productId);

      // Call the Apex method to delete the product part
      deleteProductPart({ productPartId: productId })
          .then((res) => {
            console.log("response--->" + res);
            if(res == 'Success'){
              this.dispatchEvent(
                new ShowToastEvent({
                    title: "Success",
                    message: "Product part deleted successfully.",
                    variant: "success"
                })
            );

            // Refresh the table or perform any additional logic as needed
            this.fetchProductParts();
            }
            else{
              this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: "Error deleting product part.",
                    variant: "error"
                })
            );
            }
              
          })
          .catch(error => {
              console.log("Error deleting product part:", JSON.stringify(error));           
          });
  }











  fetchProductParts() {
    this.refreshTableResult = getInsertedProductParts({ parentId: this.createdRecordId })
        .then((result) => {
            console.log("product bundle Ids fetching ---->");
            console.log("Products parts coming from apex---->", JSON.stringify(result));

            this.productBundlePartsData = result?.map((item, ind) => ({
                Id: item.Id,
                productBundlePartName: item.Name,
                PartDescription: item.Part_Description__c,
                dimension: item.Dimensions__c,
                quantity: item.cgcloud__Quantity__c,
                pricefactor: item.Price_factor__c,
                listprice: item.List_price__c,
            }));
            // this.dispatchEvent(
            //     new ShowToastEvent({
            //         title: "Success",
            //         message: "Product Parts created successfully.",
            //         variant: "success",
            //     })
            // );
        })
        .catch((error) => {
            // Handle error, if needed
            console.error(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: "Error creating Product Parts.",
                    variant: "error",
                })
            );
        });
}




  get columns() {
    return columns;
  }

  get Addcolumns() {
    return Addcolumns;
  }
}