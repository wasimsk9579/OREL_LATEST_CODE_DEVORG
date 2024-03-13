trigger UpdateQuoteDescription on Quote (before update) {
    //if (Trigger.isBefore && Trigger.isUpdate) {
        ApprovalCommentHandler.handleApprovalComments(Trigger.New);
    //}/
}