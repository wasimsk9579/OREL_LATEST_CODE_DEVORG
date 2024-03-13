public class ContactEmailTriggerHelper {

  /* public static void preventDuplicateEmail(List<Contact> newContacts) {
        Set<String> conoemail = new Set<String>();
        List<Contact> conold = [SELECT Id, Name, Email FROM Contact];
        
        for (Contact cono : conold) {
            conoemail.add(cono.Email);
        }
        
        for (Contact connew : newContacts) {
            if (conoemail.contains(connew.Email)) {
                connew.Email.addError('Email should not be duplicate');
            }
        }
    }*/
}