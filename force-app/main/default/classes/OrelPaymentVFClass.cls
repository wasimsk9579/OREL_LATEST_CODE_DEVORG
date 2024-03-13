public class OrelPaymentVFClass {
    
    public String receiptNumber { get; private set; }
    public String customer { get; private set; }
    public String orderNumber { get; private set; }
    public String invoiceNumber { get; private set; }
    public String typeOfPayment { get; private set; }
    public String modeOfPayment { get; private set; }
    public Decimal amountPaid { get; private set; }
    public String paymentReceivedBy { get; private set; }
    public String name { get; private set; }

    public OrelPaymentVFClass(ApexPages.StandardController controller) {
        String paymentId = ApexPages.currentPage().getParameters().get('id');
        system.debug('this is paymentID'+paymentId);
        Payment__c payment = [SELECT Id, Name, Type_of_payment__c, Invoice__r.Name, Advanced_Order__r.cgcloud__Order_Account__r.Name, Advanced_Order__r.Name, Amount_Paid__c, Mode_of_Payment__c FROM Payment__c WHERE Id = :paymentId LIMIT 1];
        
        receiptNumber = payment.Name;
        customer = payment.Advanced_Order__r.cgcloud__Order_Account__r.Name;
        orderNumber = payment.Advanced_Order__r.Name;
        invoiceNumber = payment.Invoice__r.Name;
        typeOfPayment = payment.Type_of_payment__c;
        modeOfPayment = payment.Mode_of_Payment__c;
        amountPaid = payment.Amount_Paid__c;
        paymentReceivedBy = '...'; // You can assign value accordingly
        name = '...'; // You can assign value accordingly
    }
}