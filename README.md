"# Related-Dealer-Validation" 
# Salesforce Opportunity Trigger and Handler

This repository contains an Apex Trigger and its Handler class for managing Opportunity records, specifically handling related dealer validations based on user and dealer mappings in Salesforce.

---

## Overview

- **Trigger Name:** `PLSI_OpportunityTrigger`
- **Handler Class:** `TriggerOpportunityHandler`

The trigger runs before insert and before update on Opportunity objects, validating dealer relationships for specific Opportunity record types and users.

---

## Features

- Checks if the `PLSI_Dealer__c` field on Opportunity has changed.
- Validates that the selected Dealer is related to the current user via ASM Dealer mappings.
- Restricts updates when Dealer is not associated with the logged-in user (except for System Administrators).
- Applies validation specifically to certain Opportunity record types:
  - Power Project
  - Power IAQ Project
  - Power Trade Project
- Applies logic only for records created after `2023-12-05 09:00:00`.
- Throws error to prevent invalid Dealer assignments.

---

## Apex Classes and Trigger

### `TriggerOpportunityHandler`

- `callRelatedDealer(List<Opportunity> olist, Map<Id, Opportunity> oldMap)`: Checks if the dealer has changed and calls validation.
- `relatedDealer(List<Opportunity> olist)`: Core logic to verify if the selected dealer is valid for the current user.

### `PLSI_OpportunityTrigger`

- Fires on before insert and before update.
- Calls `TriggerOpportunityHandler.callRelatedDealer` to enforce dealer validations.

---

## Usage

Deploy both the Apex class and trigger to your Salesforce org. The trigger automatically runs on Opportunity insert and update events, enforcing the dealer validation rules.

---

## Notes

- The validation is dependent on:
  - Custom objects: `PLSI_Dealer__c` and `PLSI_ASM_Dealer__c`.
  - User field `PLSI_User_Emp_ID__c`.
  - Specific user profiles like 'Custom Sales Team (Specifier)' and 'System Administrator'.

- Modify the date and record types in the handler logic as needed.

---
