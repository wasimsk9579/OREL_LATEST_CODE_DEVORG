trigger AttachmentTrigger on Attachment (before insert, after insert) {
    if (Trigger.isBefore) {
        AttachmentTriggerHandler.beforeInsert(Trigger.new);
    } else if (Trigger.isAfter) {
        AttachmentTriggerHandler.afterInsert(Trigger.newMap.keySet());
    }
}