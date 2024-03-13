trigger isprimarycontact on Contact (before insert, before update){
//primaryContactHelper.handlePrimaryContact(Trigger.new);
    if(trigger.isBefore && trigger.isInsert){
        primaryContactHelper.preventCreatePrimaryContactOnInsert(trigger.new);
    }

    if(trigger.isBefore && trigger.isUpdate){
        primaryContactHelper.preventPrimaryContactonUpdate(trigger.newMap,trigger.oldMap);
    }

}