public class createRunnerQuote {

        // Change return type to List<Id> to match the InvocableMethod signature
    @InvocableMethod(label='Create Runner Quote')  
    public static List<Id> createRunnerQuote(List<Id> opportunityIds) {
        List<Id> createdQuoteIds = new List<Id>();
         
        for (Id opportunityId : opportunityIds) {
            Opportunity opp = [SELECT Id, AccountId,CloseDate, Name,Amount,Standards__c, VAT_Percentage__c, VAT__c,Colour__c,Validity__c,Payment_Terms_R__c,
                             Price_List__c,Price_Validity__c,Delivery__c,Payment__c, Benificiary_Details__c, Bank_A_C__c, Bank_Details__c,Runner_Warrenty__c,
                               (SELECT Id, Product2Id, Quantity, UnitPrice, Product2.Name,Final_Price__c FROM OpportunityLineItems) 
                                FROM Opportunity WHERE Id = :opportunityId]; 
             // Query the related Account and its BillingAddress fields
              
            if(opp.amount<= 0){
                opp.amount.addError('Please add the products first');
            }
            else{
         Account oppAccount = [SELECT Id, Name,BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,
                               ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry,
                               (SELECT Id, Name, Email, phone FROM Contacts) 
                                  FROM Account WHERE Id = :opp.AccountId];
            
            Contact relatedContact = new Contact(); // Initialize a Contact object
            if (oppAccount.Contacts != null && !oppAccount.Contacts.isEmpty()) {
                // Retrieving the first contact related to the account, you might refine this logic as per your use case
                relatedContact = oppAccount.Contacts[0];
            }
            
            
            // Determine the Pricebook based on the Opportunity's Record Type Name
           // String recordTypeName = [SELECT Name FROM RecordType WHERE Id = :opp.RecordTypeId].Name;  
            Pricebook2 selectedPricebook = [SELECT Id FROM Pricebook2 WHERE Name = 'Runner Pricebook' LIMIT 1];
            
            Quote newQuote = new Quote(
                OpportunityId = opp.Id,
                Name = opp.Name + ' Quote',
                Pricebook2Id = selectedPricebook.Id,
                ContactId = relatedContact.Id,
                Email = relatedContact.Email,
                Phone = relatedContact.Phone,
                VAT__c = opp.VAT__c,
                VAT_Percentage__c = opp.VAT_Percentage__c,
                Validity__c = opp.Validity__c,
                Price_list__c = opp.Price_List__c,
                Price_Validity__c= opp.Price_Validity__c,
                Delivery__c = opp.Delivery__c,
                Payment__c = opp.Payment__c,
                Benificiary_Details__c = opp.Benificiary_Details__c,
                Bank_A_C__c = opp.Bank_A_C__c,
                Bank_Details__c = opp.Bank_Details__c,
                Runner_Warrenty__c = opp.Runner_Warrenty__c,
                Payment_Terms_R__c = opp.Payment_Terms_R__c,
                Tax=0,
                 BillingStreet = oppAccount.BillingStreet,
                 BillingCity = oppAccount.BillingCity,
                 BillingState = oppAccount.BillingState,
                 BillingPostalCode = oppAccount.BillingPostalCode,
                 BillingCountry = oppAccount.BillingCountry,
                 ShippingStreet = oppAccount.ShippingStreet,
                 ShippingCity = oppAccount.ShippingCity,
                 ShippingState = oppAccount.ShippingState,
                 ShippingPostalCode = oppAccount.ShippingPostalCode,
                 ShippingCountry = oppAccount.ShippingCountry
            );
            insert newQuote; 
            
            List<QuoteLineItem> lineItems = new List<QuoteLineItem>();
            for (OpportunityLineItem oli : opp.OpportunityLineItems) {
                // Query the Price Book Entry for this OpportunityLineItem 
                PricebookEntry pricebookEntry = [SELECT Id, UnitPrice, Product2Id FROM PricebookEntry 
                                                WHERE Product2Id = :oli.Product2Id AND Pricebook2Id = :selectedPricebook.Id LIMIT 1];
                
                QuoteLineItem lineItem = new QuoteLineItem(
                    QuoteId = newQuote.Id, 
                    Product2Id = oli.Product2Id,
                    Quantity = oli.Quantity,
                    UnitPrice = oli.UnitPrice,
                    PricebookEntryId = pricebookEntry.Id,
                    Final_Price__c = oli.Final_Price__c   
                );
                lineItems.add(lineItem);
            } 
            insert lineItems; 
            
            // Add the ID of the created Quote to the list
            createdQuoteIds.add(newQuote.Id);
        }
        }
        return createdQuoteIds;
    }
}