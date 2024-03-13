trigger QuoteTrigger on Quote (before update, after update) {
    if (Trigger.isBefore && Trigger.isUpdate) {
        ApprovalCommentHandler.handleApprovalComments(Trigger.New);
       // ValidateDiscountQuoteHelper.throwError(Trigger.New);
    } else if (Trigger.isAfter && Trigger.isUpdate) {
        QuoteNotification.sendApproveNotification(Trigger.new, Trigger.oldMap);
        QuoteNotification.sendRejectNotification(Trigger.new, Trigger.oldMap);
        DiscountHelper.getQuoteLineItems(Trigger.new, Trigger.oldMap);
        TaskCreationEmailHelper.createTaskOnOpportunity(Trigger.new, Trigger.oldMap);
        QuoteNotification.sendAcceptanceEmail(Trigger.new, Trigger.oldMap);
        QuoteNotification.sendRejectionEmail(Trigger.new, Trigger.oldMap);
    }
}