trigger ContactTrigger on Contact ( after insert,after update ) {
     if( Trigger.isAfter && Trigger.isInsert ){
         ContactTriggerHandler.createPrimaryContact( Trigger.New);
     }
     if( Trigger.isAfter && Trigger.isUpdate ){
     	ContactTriggerHandler.updatePrimaryCOntact( Trigger.New );
     }
    
}