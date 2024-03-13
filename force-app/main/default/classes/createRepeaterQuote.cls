public with sharing class createRepeaterQuote {
    
    // Change return type to List<Id> to match the InvocableMethod signature
    @InvocableMethod(label='Create Repeater Quote')
    public static List<Id> createStandardQuote(List<Id> opportunityIds) {
        List<Id> createdQuoteIds = new List<Id>();
        
        for (Id opportunityId : opportunityIds) {
            Opportunity opp = [SELECT Id, AccountId,CloseDate, Name, RecordTypeId,Amount,Standards__c, VAT_Percentage__c, VAT__c,Colour__c,
                               Rep_Delivery__c,Rep_Validity__c, Protection__c,Tax_Type__c,AFP_Perent__c,PFP_Percent__c,TPC_Percent__c,
                               (SELECT Id, Product2Id, Quantity, UnitPrice, Product2.Name,AFP_Percent__c,PFP_Percent__c,TPC_Percent__c,Final_Price__c,Gross_Profit__c,NBT__c,SSLT__c,Govt_Entity__c,
                                Electrical_Labour_Hours__c,Transport_Charges__c, Instalation_Charges__c, Electrical_Labour__c,VAT__c,
                               Instalation_Charges_Hours__c,Transport_Charges_Hours__c, Engraving_Tags_With_Legend_Plates_Hours__c, Engraving_Tags_With_Legend_Plates__c FROM OpportunityLineItems) 
                                FROM Opportunity WHERE Id = :opportunityId];
            if(opp.amount<= 0){
                opp.amount.addError('Please add the products first');
            }
            else{
         Account oppAccount = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,
                               ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry,
                               (SELECT Id, Name, Email, phone FROM Contacts) 
                                  FROM Account WHERE Id = :opp.AccountId];
            
            Contact relatedContact = new Contact(); // Initialize a Contact object
            if (oppAccount.Contacts != null && !oppAccount.Contacts.isEmpty()) {
               
                relatedContact = oppAccount.Contacts[0];
            }
            
            
            // Determine the Pricebook based on the Opportunity's Record Type Name
            String recordTypeName = [SELECT Name FROM RecordType WHERE Id = :opp.RecordTypeId].Name;  
            Pricebook2 selectedPricebook = [SELECT Id FROM Pricebook2 WHERE Name = 'SriLankan Currency PB' LIMIT 1];
            
            Quote newQuote = new Quote(
                OpportunityId = opp.Id,
                Name = opp.Name + ' Quote',
                Pricebook2Id = selectedPricebook.Id,
                ContactId = relatedContact.Id,
                Email = relatedContact.Email,
                Phone = relatedContact.Phone,
                VAT__c = opp.VAT__c,
                VAT_Percentage__c = opp.VAT_Percentage__c,
                Colour__c = opp.Colour__c,
                Standard__c = opp.Standards__c,
                Protection__c = opp.Protection__c,
                Rep_Validity__c = opp.Rep_Validity__c,
                Rep_Delivery__c = opp.Rep_Delivery__c,
                Tax_Type__c= opp.Tax_Type__c,
                Tax=0 ,
                AFPPerent__c = opp.AFP_Perent__c,
                PFPPERCENT__c = opp.PFP_Percent__c,
                TPCpercent__c = opp.TPC_Percent__c,
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
                    Final_Price__c = oli.Final_Price__c,
                    AFPpercent__c = oli.AFP_Percent__c,
                    PFPPERCENT__c = oli.PFP_Percent__c,
                    TPCpercent__c = oli.TPC_Percent__c,
                    Electrical_Labour__c = oli.Electrical_Labour__c,
               		Instalation_Charges__c = oli.Instalation_Charges__c,
                    Transport_Charges__c = oli.Transport_Charges__c,
                    Engraving_Tags_With_Legend_Plates__c = oli.Engraving_Tags_With_Legend_Plates__c,
                    Electrical_Labour_Hours__c = oli.Electrical_Labour_Hours__c,
                    Instalation_Charges_Hours__c = oli.Instalation_Charges_Hours__c,
                    Transport_Charges_Hours__c = oli.Transport_Charges_Hours__c,
                    Engraving_Tags_With_Legend_Plates_Hours__c = oli.Engraving_Tags_With_Legend_Plates_Hours__c,
                    Gross_Profit__c= oli.Gross_Profit__c,
                    NBT__c = oli.NBT__c,
                    SSLT__c = oli.SSLT__c,
                    Govt_Entity__c = oli.Govt_Entity__c
                    
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