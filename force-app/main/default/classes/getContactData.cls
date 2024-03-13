public with sharing class getContactData {
    @AuraEnabled(cacheable=true)
    public static List<Contact> fetchContacts() {
        List<Contact> conList =[Select id, name from contact];
        return conList;
    }
}