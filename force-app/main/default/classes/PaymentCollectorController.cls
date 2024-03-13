global without sharing class PaymentCollectorController {
    public final Orl_invoice__c originalInvoice;
    public string VATNO {get;set;}
    public string collectorID {get;set;}
    public string Amount {get;set;}
    public string AmountPaid {get;set;}
    public Orl_invoice__c Invoice{get;set;}
    public String PaymentType{get;set;}
    public String recordId { get; set; }
    public boolean renderData {get;set;}
    public boolean renderData1 {get;set;}
   	public boolean DisplayPopup {get; set;}     
	public Boolean disableSaveButton{get; set;}     
    public Boolean showPartial{get; set;}
    public Boolean showFull{get; set;}	  
    public List<Payment__c> paymentData {get; set;}	
    public Payment__c selectedPayment { get; set; }
    public string selectedPaymentId{get;set;}
     public Boolean showPaymentDetails { get; set; }
    //public Boolean showDataTable { get; set; }
 
   
//public boolean paymentSuccessful { get; set; }

	public Set<String> collectorIds = new Set<String>();
    public String AccountId;
    public PaymentCollectorController(ApexPages.StandardController stdController) {  
        showPaymentDetails=false;
        recordId = ApexPages.currentPage().getParameters().get('Id');
      	System.debug('recordId=> '+recordId);
        Invoice = [select id,Orl_Invoice_No__c,Advanced_Order__r.cgcloud__Order_Account__r.Name, Advanced_Order__r.cgcloud__Gross_Total_Value__c,
                   name, Total_Amount_Paid__c, Due_Amount__c from Orl_invoice__c where id =: recordId ]; 
        AccountId = Invoice.Advanced_Order__r.cgcloud__Order_Account__c;
        System.debug('AccountId::'+AccountId);
        List<Contact> conList = [Select Id, Collector_ID__c, AccountId from Contact where Collector_ID__c!=null AND AccountId=:AccountId];
        for(Contact con: conList){
            collectorIds.add(con.Collector_ID__c);
        }
        System.debug('Invoice=> '+Invoice);
        this.disableSaveButton = false;
        this.showPartial = false;
        this.showFull = true;
        System.debug('disableSaveButton::'+this.disableSaveButton);
        System.debug('showPartial::'+this.showPartial);
        
       //  showPaymentDetails = false;
      
       
        InvoicesCollectorController();
        
       
     
    }
    
   

    public  void createPayment(){
        
     
        //showPaymentDetails = true;
        System.debug('this amount::'+this.Amount);
        System.debug('PaymentType::'+PaymentType);
        if(collectorIds!=null && collectorIds.size()>0 && !collectorIds.contains(this.collectorID))
        {
            System.debug('if entered::');
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Please enter valid Collector Id!!'));
        }else if(PaymentType=='Partial Payment' && String.isBlank(Amount)){
           
            System.debug('else if entered::');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Please enter valid Amount value!!'));
        }else{
            System.debug('collectorIds::'+collectorIds);
            System.debug('this.collectorID::'+this.collectorID);
            this.disableSaveButton = true;
            System.debug('disableSaveButton::'+this.disableSaveButton);
            
            Payment__c Payment = new Payment__c();
            Payment.Type_of_payment__c = this.PaymentType;
            if(PaymentType=='Partial Payment'){
                Payment.Amount_Paid__c = Decimal.valueOf(this.Amount);
            }
            
            if(PaymentType=='Full Payment'){
                Payment.Amount_Paid__c = Invoice.Due_Amount__c;
                
            }
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Payment of LKR.'+Payment.Amount_Paid__c+' done successfully!!'));
            //Payment.Amount__c = Invoice.Advanced_Order__r.cgcloud__Gross_Total_Value__c - Invoice.Total_Amount_Paid__c -Decimal.valueOf(this.Amount);
            Payment.Invoice__c = Invoice.Id;
            Payment.Name = Invoice.name+' Payment';
            Payment.Advanced_Order__c = Invoice.Advanced_Order__c;
            Payment.Collector_ID__c = collectorID;
            insert Payment;
          
            
          //  String script = 'document.getElementById("{!$Component.paymentInfoBlock.paymentType}").value = "Full Payment";';
       // ApexPages.currentPage().getParameters().put('js', script);
          //  if(Payment != null){
            //    Amount = null;
           // }
           
          
          
          //  InvoicesCollectorController();
          // Amount = null;
           
            
            Orl_invoice__c updatedInvoice = new Orl_invoice__c(Id=Invoice.Id);
            if(PaymentType=='Full Payment')
                updatedInvoice.Invoice_Status__c='Closed';
            else
                updatedInvoice.Invoice_Status__c='open';
            update updatedInvoice;
            
            Invoice = [SELECT Id, Orl_Invoice_No__c, Advanced_Order__r.cgcloud__Order_Account__r.Name, 
                      Advanced_Order__r.cgcloud__Gross_Total_Value__c, Name, Total_Amount_Paid__c, Due_Amount__c 
               FROM Orl_invoice__c 
               WHERE Id = :recordId];

            Amount = '';
        
        }
           
         togglePaymentDetails();
        InvoicesCollectorController();
       
         
      this.showPartial = false;
        this.showFull = true;
        
      if(this.showFull == true ){
        PaymentType='Full Payment';                
//
      } 
    }
  

    public void paymentTypeHandler(){
        if(PaymentType=='Partial Payment'){
            this.showPartial = true;
        	this.showFull = false;
        }
        if(PaymentType=='Full Payment'){
            this.showPartial = false;
        	this.showFull = true;
        }
        System.debug('Payment type changed::');
        System.debug('showPartial::'+this.showPartial);
        System.debug('showFull::'+this.showFull);


        }
/*      public void InvoicesCollectorController() {
        recordId = ApexPages.currentPage().getParameters().get('Id');
        System.debug('recordId=> ' + recordId);
        paymentData = [SELECT Id, Invoice__c, Name, Type_of_payment__c, Advanced_Order__c, Collector_ID__c, Amount_Paid__c, Mode_of_Payment__c 
                       FROM Payment__c WHERE Invoice__c = :recordId];
    }*/
    
    
    
    
    public void InvoicesCollectorController() {
   // recordId = ApexPages.currentPage().getParameters().get('Id');
    //System.debug('recordId=> ' + recordId)
    //test        
   paymentData = [SELECT Id, Invoice__c, Name, Type_of_payment__c, Advanced_Order__c,Advanced_Order__r.Name,Invoice__r.Name,Collector_ID__c, Amount_Paid__c, Mode_of_Payment__c 
                 FROM Payment__c WHERE Invoice__c= :recordId ORDER BY 	CreatedDate DESC];
        system.debug('this:-'+paymentData);
}
    
    
    
  public PageReference navigateToAnotherPage() {
   if (paymentData != null && !paymentData.isEmpty()) {
        //Replace 'Your_Target_Page' with the name of your target Visualforce page
       // PageReference pageRef = Page.paymentrecieptpdf;
      //  pageRef.getParameters().put('paymentId', paymentData[1].Id);
       // pageRef.setRedirect(true);
        //return Page.paymentrecieptpdf;
        //
       // system.debug('this is for'+pageRef);
       // 
  
        //String paymentId = paymentData[0].Id; 
        //
        system.debug('the selected id is>>'+selectedPaymentId);
       
        String secondPageUrl ='/apex/paymentrecieptpdf?id='+selectedPaymentId;
      
       return new PageReference(secondPageUrl);
      
       
        

  }  
        
    else{
        // Handle the case where no payment records are found
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No payment records found.'));
        return null; // or return a PageReference to an error page
    }
}
    
//public PageReference toggleSections() {       
  //showDataTable = !showDataTable;   
       //showDataTable = true ;
//return null;     
//}
    


    // existing controller logic....
public   void  togglePaymentDetails(){
      if (!String.isBlank(collectorID) && collectorIds.contains(collectorID)) 
       // if (isNewPaymentAdded || (!String.isBlank(collectorID) && collectorIds.contains(collectorID))) 
       {
        
        //showPaymentDetails = !showPaymentDetails;
        //showPaymentDetails = !showPaymentDetails;
       showPaymentDetails = true ;
      
         
       }

      else {
        // If Collector ID is not provided, set showPaymentDetails to false
       showPaymentDetails = false;
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter thE Valid Collector ID.'));
          
      }
   
    
    
    //return null;   
   }
    
   
    
    
   
     
}