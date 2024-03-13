public class orelinvoiceattachtriggercontroller {
public static void createpdf(list<Orl_invoice__c> invlist)
{
    for(Orl_invoice__c invoice:invlist)
    {
        orelinvoiceattachcontroller.generatePDFAndSendEmail(invoice.Id);
    }
}
}