trigger PLSI_OpportunityTrigger on Opportunity (after insert,after delete,after update,before insert,before update) {
    System.debug('count');
    //if(triggerhandlerRecursive.runOnce()){
    if(Trigger.isInsert && Trigger.isBefore){
    TriggerOpportunityHandler.callRelatedDealer(Trigger.New, trigger.oldmap);
     }

    if(Trigger.isUpdate && Trigger.isBefore){
         //for IB project Enquiry field update
        TriggerOpportunityHandler.callRelatedDealer(Trigger.New,trigger.oldMap);
    }  
}