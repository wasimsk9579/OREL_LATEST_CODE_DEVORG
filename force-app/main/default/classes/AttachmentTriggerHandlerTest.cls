@isTest
private class AttachmentTriggerHandlerTest {
    @isTest
    static void testBeforeInsert() {
        
         Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;

        // Create test Contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = testAccount.Id,
            Email = 'test@example.com',
            Phone = '1234567890'
        );
        insert testContact;

        // Create test Opportunity
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = testAccount.Id,
            CloseDate = Date.today(),
            Amount = 1200,
            VAT_Percentage__c = 10,
            VAT__c = 'Include',
            StageName = 'Qualification'
        );
        insert testOpportunity;

        // Create test data: Quote and Attachment
        Quote testQuote = new Quote(Name = 'Test Quote', opportunityId = testOpportunity.Id);
        insert testQuote;

        Attachment testAttachment = new Attachment(
            ParentId = testQuote.Id,
            Name = 'Test Attachment',
            Body = Blob.valueOf('Test Attachment Body')
        );

        Test.startTest();
        // Call the beforeInsert method
        AttachmentTriggerHandler.beforeInsert(new List<Attachment>{testAttachment});
        Test.stopTest();
    }
    
     @isTest
    static void testAfterInsert() {
 Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;

        // Create test Contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = testAccount.Id,
            Email = 'test@example.com',
            Phone = '1234567890'
        );
        insert testContact;

        // Create test Opportunity
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = testAccount.Id,
            CloseDate = Date.today(),
            Amount = 1200,
            VAT_Percentage__c = 10,
            VAT__c = 'Include',
            StageName = 'Qualification'
        );
        insert testOpportunity;

        // Create test data: Quote and Attachment
        Quote testQuote = new Quote(Name = 'Test Quote', opportunityId = testOpportunity.Id);
        insert testQuote;

        Attachment testAttachment = new Attachment(
            ParentId = testQuote.Id,
            Name = 'Test Attachment',
            Body = Blob.valueOf('Test Attachment Body')
        );
        insert testAttachment;

        // Get the Id of the inserted attachment
        Set<Id> attachmentIds = new Set<Id>{testAttachment.Id};

        Test.startTest();
        // Call the afterInsert method
        AttachmentTriggerHandler.afterInsert(attachmentIds);
        Test.stopTest();

        // Verify that the Counter__c field on the Quote record is updated
        testQuote = [SELECT Id, Version__c FROM Quote WHERE Id = :testQuote.Id];
        System.assertEquals(1, testQuote.Version__c, 'Version number should be updated to 1 after insert');
    }
}