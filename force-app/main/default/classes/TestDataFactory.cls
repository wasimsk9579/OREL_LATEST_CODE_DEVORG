public class TestDataFactory {
    
     public static List<Account> createAccount(Integer numofAcc){
        List<Account> AccList = new List<Account>();
        for(Integer i=0; i< numofAcc; i++){
            Account createAcc = new Account(Name='Test Account' + i);
            AccList.add(createAcc);
        }
        insert AccList;
        return AccList;
    }
    
      public static List<Contact> createContact(List<Account> AccountData){
        List<Contact> ConList = new List<Contact>();
        for(Account Acc : AccountData){
            Contact createCon = new Contact( FirstName = 'Test',
            LastName = 'Contact',
            AccountId = Acc.Id,
            Email = 'test@example.com',
            Phone = '1234567890');
             ConList.add(createCon);
        }
          
        insert ConList;
        return ConList;
    }
    
    
    
    public static List<Opportunity> createOpportunity(Integer numofOpp){
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i=0; i< numofOpp; i++){
            Opportunity createOpp = new Opportunity(Name='Test123' + i, StageName='Qualification', CloseDate=Date.today());
            oppList.add(createOpp);
        }
        insert oppList;
        return oppList;
    }
    
    
     public static List<cgcloud__Product_Template__c> createTemplpate(Integer NumTemplate){
          List<cgcloud__Product_Template__c> TempList = new List<cgcloud__Product_Template__c>();
            cgcloud__Product_Template__c templates = new cgcloud__Product_Template__c(
        	Name = 'Test Template',
            cgcloud__Sales_Org__c = '0001',
            cgcloud__Active__c = true,
            cgcloud__Description_Language_1__c = 'test Description'
        	);
                 TempList.Add(templates);
                 Insert TempList;
                 Return TempList;
             }
    
    public static List<OpportunityLineItem> createOpportunityLineItem(List<Opportunity> opportunityData, String pricebookEntryId){
        List<OpportunityLineItem> opplineitemList = new List<OpportunityLineItem>();
        for(Opportunity op : opportunityData){
            OpportunityLineItem newoli = new OpportunityLineItem(
                OpportunityId = op.Id,
                PricebookEntryId = pricebookEntryId,
                UnitPrice = 5,
                Quantity = 10
            );
            opplineitemList.add(newoli);
        }
        insert opplineitemList;
        return opplineitemList;
    }
    
    public static List<Quote> createQuote(Integer quoteCount, Id OpportunityId) {
        List<Quote> quoteToInsert = new List<Quote>();
        for(Integer i = 0; i < quoteCount; i++) {
            Quote createQte = new Quote(Name = 'Test' + i,Status='Draft' ,Customer_Response__c='test 1234',  OpportunityId = OpportunityId);
            quoteToInsert.add(createQte);
        }
        insert quoteToInsert;
        return quoteToInsert;
    }
    
    public static List<QuoteLineItem> createQuoteLineItem(List<Quote> quoteList, String pricebookEntryId) {
        List<QuoteLineItem> QuoteLineItemList = new List<QuoteLineItem>();
        for(Quote qt : quoteList) {
            QuoteLineItem qli = new QuoteLineItem(QuoteId = qt.Id,
                                                  PricebookEntryId = pricebookEntryId,
                                                  UnitPrice = 5,
                                                  Quantity = 10);
            QuoteLineItemList.add(qli);
        }
        insert QuoteLineItemList;
        return QuoteLineItemList;
    }
    public static List<Task> createTask(List<Opportunity> opportunityData, Id ownerId) {
        List<Task> taskList = new List<Task>();
        
        for (Opportunity op : opportunityData) {
            Task newTask = new Task();
            newTask.WhatId = op.Id;
            newTask.OwnerId = ownerId;
            newTask.Status = 'Open';
            newTask.Priority = 'Normal';
            newTask.Subject = 'Create Drawings'; 
            newTask.Description = 'Request for drawings from the customer.';
            taskList.add(newTask);
        }
        
        insert taskList;
        
        return taskList;
    }
    
    
    
}