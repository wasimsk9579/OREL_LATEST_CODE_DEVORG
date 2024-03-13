import { LightningElement, track,api, wire } from "lwc";
import searchQuotes from "@salesforce/apex/orelQuoteSearchController.searchQuotes";
import getQuoteLineItems from "@salesforce/apex/orelQuoteSearchController.getQuoteLineItems";
import handleAfterInsert from "@salesforce/apex/orelQuoteSearchController.handleAfterInsert";

import { CurrentPageReference } from "lightning/navigation";


const QUOTE_COLUMNS = [
  { label: "Quote Name", fieldName: "Name", type: "text" },
  { label: "Quote Number", fieldName: "QuoteNumber", type: "text" },
];

const QUOTE_LINE_ITEM_COLUMNS = [
  { label: "productId", fieldName: "Id", type: "text" },
  { label: "Name", fieldName: "Name", type: "text" },
];

const PRODUCT_PART_COLUMNS = [
  { label: "Dimension", fieldName: "dimension", type: "text" },
  { label: "Desc", fieldName: "description", type: "text" }, // Replace with your actual field names
  { label: "Quantity", fieldName: "quantity", type: "number" },
  { label: "Master Product", fieldName: "masterProductName", type: "text" },
  // Add additional fields as needed
];

export default class OrelQuoteSearch extends LightningElement {

  @wire(CurrentPageReference)
    pageRefData;

    @api recordId;

    opportunityRecordId;

    connectedCallback() {
      this.opportunityRecordId = this.pageRefData.attributes.recordId;
      console.log(
        "opportunity id from create bundle button received ---->",
        this.opportunityRecordId
      );
    }


  @track quoteNumber = "";
  @track quotes;
  @track quoteOptions;
  @track selectedQuoteId;
  @track quoteLineItems;
  @track quoteColumns = QUOTE_COLUMNS;
  @track quoteLineItemColumns = QUOTE_LINE_ITEM_COLUMNS;
  @track productPartColumns = PRODUCT_PART_COLUMNS;
  @track selectedProductParts;
  @track selectedProductId;

  handleQuoteNumberChange(event) {
    this.quoteNumber = event.target.value;
  }

  searchQuote() {
    searchQuotes({ quoteNumber: this.quoteNumber })
      .then((result) => {
        this.quotes = result;
      })
      .catch((error) => {
        console.error("Error fetching quotes:", error);
      });
  }
  partIds;
  handleRowSelection(event) {
    const selectedRows = event.detail.selectedRows;
    if (selectedRows.length > 0) {
      this.selectedQuoteId = selectedRows[0].Id;
      console.log("selected Quote ID----> " + this.selectedQuoteId);
      getQuoteLineItems({ quoteId: this.selectedQuoteId })
        .then((result) => {
          console.log("new results of lie items--->", JSON.stringify(result));
          this.quoteLineItems = result.map((item) => ({
            ...item,
            Name: item.Name,
          }));
          console.log("new quote items--->", this.quoteLineItems);
        })
        .catch((err) => {
          console.log(err);
        });
    }
  }
  selectedRows;
  finalLineItems;
  handleProductRowSelection(event) {
    try {
        this.selectedRows = event.detail.selectedRows;
        console.log("new item lines--->", this.selectedRows);

        this.finalLineItems = [];

        this.selectedProductParts = this.selectedRows.map((item) => {
            const productParts = item.cgcloud__Product_Parts__r.map((ele) => ({
                ...item,
                description: ele.Part_Description__c,
                quantity: ele.cgcloud__Quantity__c,
                dimension: ele.Dimensions__c,
                masterProductName: item.Name,
            }));

            this.finalLineItems.push(...productParts);

            return {
                selectedProductIds: item.Id,
                description: item.cgcloud__Product_Parts__r.map((e) => e.Part_Description__c),
                quantity: item.cgcloud__Product_Parts__r.map((e) => e.cgcloud__Quantity__c),
                dimension: item.cgcloud__Product_Parts__r.map((e) => e.Dimensions__c),
                masterProductName: item.Name,
            };
        });

        console.log("this stupid data table data---->", this.selectedProductParts);
    } catch (error) {
        console.log(error);
    }

    console.log("finally ===>", this.finalLineItems);
}

  handleInsert() {
    console.log('i invoked')
    const selectedProducts = this.finalLineItems.map((e)=>e.Id);
    const selectedIds=[...new Set(selectedProducts)];
    console.log('selectedIds final one',selectedProducts,selectedIds)

    handleAfterInsert({ parentIds: selectedIds , opportunityRecordId: this.opportunityRecordId })
      .then((result) => {
        console.log("After Insert Invoking---->");

        console.log("Opportunity Line Item inserted successfully:", result);
        // You can handle any additional logic here, such as refreshing the Opportunity record page
      })
      .catch((error) => {
        console.error("Error inserting Opportunity Line Item:", error);
      });
  }
}