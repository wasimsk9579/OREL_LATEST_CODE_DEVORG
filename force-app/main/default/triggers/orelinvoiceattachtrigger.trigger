trigger orelinvoiceattachtrigger on Orl_invoice__c (after insert) {
    if(trigger.isafter && trigger.isinsert)
    {
            orelinvoiceattachtriggercontroller.createpdf(trigger.new);
    }
}