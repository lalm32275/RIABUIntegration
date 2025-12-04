public class RiabuAccountCreationQueue implements Queueable, Database.AllowsCallouts {
    private String AccountId;
    public RiabuAccountCreationQueue( Id accId ){
        this.AccountId = accId;
    }
    public void execute( QueueableContext qc){
        Account acc = [SELECT Id, RiabuAccountId__c FROM Account WHERE Id = :AccountId LIMIT 1];
        if (acc.RiabuAccountId__c != Null ) return;

         CustomerCreationService.createCustomer( AccountId );
         System.enqueueJob(new RiabuAccountFetchQueue( AccountId ) );
    }
}