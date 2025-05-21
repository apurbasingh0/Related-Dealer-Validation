/**********************************************************************************
* ClassName: The relatedDealer method in TriggerOpportunityHandler validates that the dealer selected by the user is mapped to them. If not, it throws an error to prevent unauthorized dealer selection.
* Created By: Apurba Singh
* Created on: 19-03-2021
* Description:It is a helper class.
* Modified on :
* Modified by :
***********************************************************************************/
public class TriggerOpportunityHandler {
   
    public static void callRelatedDealer(List<opportunity> olist, Map<Id,Opportunity> oldmap){
        list<Opportunity> passList = new list<Opportunity>();
        
        for(opportunity op:olist){
            if(oldMap==null || op.PLSI_Dealer__c != oldMap.get(op.Id).PLSI_Dealer__c){
                passList.add(op);
            }
        }
        
        if(passList.size()>0)
            relatedDealer(passList);
    }
    
    //added by apurba singh for related dealer mapping in power and iaq oppo   
    public static void relatedDealer(List<opportunity> olist)
    {
        String currentUserEmpId = UserInfo.getUserId();
        User userli = [Select Id, Name, PLSI_User_Emp_ID__c,Profile.Name From User Where Id =: currentUserEmpId LIMIT 1];  
        Set<Id> oppoanddealerid = new Set<Id>();
        Map<String, String> dealerIdAcctNo= new Map<String, String>();
        Map<String, list<PLSI_ASM_Dealer__c>> actNoAsmMap = new Map<String, list<PLSI_ASM_Dealer__c>>();
        for (Opportunity op : olist) {
            if (op.PLSI_Dealer__c != null) {
                oppoanddealerid.add(op.PLSI_Dealer__c);
                
            }
        }
        List<PLSI_Dealer__c> DealerRecords = [Select Id, Name,ORGANIZATION_CODE__c,org_Id__c, ACCOUNT_NUMBER__c from PLSI_Dealer__c WHere Id IN :oppoanddealerid AND Active__c= true];
        for (PLSI_Dealer__c dealer : DealerRecords) {
            dealerIdAcctNo.put(dealer.Id, dealer.ACCOUNT_NUMBER__c);
        }
        List<PLSI_ASM_Dealer__c> ASMDealersWithDealers = [Select Id, Name, Dealer__r.id, Dealer__r.Name, SALESREP_NUMBER__c, Dealer__r.ACCOUNT_NUMBER__c from PLSI_ASM_Dealer__c WHere SALESREP_NUMBER__c =: userli.PLSI_User_Emp_ID__c AND Dealer__r.ACCOUNT_NUMBER__c IN:dealerIdAcctNo.Values() AND Active__c= true];
        System.debug('ASMDealersWithDealers'+ASMDealersWithDealers);
        for (PLSI_ASM_Dealer__c asmDealer : ASMDealersWithDealers) {
            if(!actNoAsmMap.containsKey(asmDealer.Dealer__r.ACCOUNT_NUMBER__c)){
              actNoAsmMap.put(asmDealer.Dealer__r.ACCOUNT_NUMBER__c, new list<PLSI_ASM_Dealer__c>()); 
                actNoAsmMap.get(asmDealer.Dealer__r.ACCOUNT_NUMBER__c).add(asmDealer);
            }
            actNoAsmMap.get(asmDealer.Dealer__r.ACCOUNT_NUMBER__c).add(asmDealer);
        }   
        System.debug('oppoanddealerid'+oppoanddealerid);
		System.debug('dealerIdAcctNo'+dealerIdAcctNo);
		System.debug('actNoAsmMap'+actNoAsmMap);
		System.debug('DealerRecords'+DealerRecords);
		System.debug('ASMDealersWithDealers'+ASMDealersWithDealers);

        for (Opportunity opp : olist) {
            String recordtypename = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(opp.recordTypeID).getname();
            Opportunity objOldOppo = trigger.isUpdate ? ((Map<Id, Opportunity> ) trigger.oldmap).get(opp.id ) : null;
            if( (trigger.isInsert )||( trigger.isUpdate && (objOldOppo.CreatedBy.Profile.Name == 'Custom Sales Team (Specifier)'
                                                            || objOldOppo.PLSI_Dealer__c == null ) && Date.valueOf(objOldOppo.CreatedDate) > Date.valueOf('2023-12-05 09:00:00'))){
                                                                if (opp.PLSI_Dealer__c != null && (recordtypename == 'Power Project' || recordtypename == 'Power IAQ Project' || recordtypename == 'Power Trade Project')) {
                                                                    Boolean isValidDealer = false;
                                                                    isValidDealer = (actNoAsmMap != null && !actNoAsmMap.isEmpty() && actNoAsmMap.get(dealerIdAcctNo.get(opp.PLSI_Dealer__c)).Size()>0)?true:false;
                                                                       
                                                                    if (!isValidDealer && userli.Profile.Name != 'System Administrator') {
                                                                        opp.addError('The selected Dealer is not related to the current user.');
                                                                    }
                                                                }
                }
        }
    }
    
   
      
    }