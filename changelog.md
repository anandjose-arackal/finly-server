# Changelog
All notable changes to this project will be documented in this file. Always add new logs to 
beginning of this file.

## 2021-05-17
  - Fix: Currency and tax_type lookup fix.

## 2021-05-17
  - Feat: Updating migration, fixing lookup issue and stabilizing the invoice forms.

## 2021-05-17
- Fix: Added filter_unique_check method for models to use it for scoping records for uniqueness check. And updated forms unique validation to use the same
## 2021-05-03
- Fix: Fix for base currency issue. 

## 2021-05-01
- Fix: Fix for filter issue, filter not populating. 
- feat: Custom fields for Bbps utility subscriptions.

## 2021-04-30
- Feat: NonPoInvoice form migration, payment ticket and multi currency changes, with feature flag added to the old ui

## 2021-04-17
- Fix: Validation on total invoiced quantity against purchase order quantity removed for service items

## 2021-04-13
 - Fix: Updating the user base dlrm for credit note.
 - fix: Updating invoice for vendor location.

## 2021-04-08
 - feat: Create export templates for new companies when created.

## 2021-04-07
- Fix: Vendor policy check was not checking for company. Patched this security gap.

## 2021-03-01
  - FormMigration: Updating migration to handle custom field migrations.
  - Updating payment ticket changes for invoice.

## 2021-03-31
  - Fix: use user roles instead of policy user roles to properly filter export templates.

## 2021-03-30
  - Updating model for vendor form.

## 2021-03-26
- FIX: Removing google_oauth2 gem

## 2021-03-25
  - Security: Updating the authorization policy for invoice and vendors. 
  - Removing changes for invoice policy authorization.

## 2021-03-23
  - Updating the reporting values and payment ticket values.
  - Adding support for multi currency export.

## 2021-03-22
  - Updating the invoice form migration script and fixing migration bugs

## 2021-03-21
  - Feat: Non Po Invoice Forms release
  - Fix: Moved OTP mailers from default redis queue to payment creation queue

## 2021-03-19
  - Fix: Moved OTP mailers from default redis queue to payment creation queue

## 2021-03-19
  - Updating the non-po-form migration script

## 2021-03-21
  - Feat: Non Po Invoice Forms release

## 2021-03-19
  - Fix: Moved OTP mailers from default redis queue to payment creation queue

## 2021-03-16
  - Updating the authentication flow 
  - Updating sso config
  - Updating the sso opt verification

## 2021-03-14
  - Updating the sso from request_store adding error messages and sso config movied to procedure

##2021-03-12
  - Updating the invoice and purchase_order validations

##2021-03-11
  - Fix: `Vendor Payment` Purchase Order advance Amount in upaid, the status will change to `close`  while closing a purchase order

    The re-opeing action in purchase order will revoke the Purchase advance amount status to previous status if it a non paid advance

##2021-03-10
 - Fix: Deleted user's policy user roles was trying render and leads to nil issue, 
    Policy User Role index only render existing user roles
    
  The re-opeing action in purchase order will revoke the Purchase advance amount status to previous status if it a non paid advance

##2021-03-10

  The re-opeing action in purchase order will revoke the Purchase advance amount status to previous status if it a non paid advance

##2021-03-10

  - Fix: Deleted user's policy user roles was trying render and leads to nil issue, 
        Policy User Role index only render existing user roles
   
##2021-03-08
  - SMP service api updated, by adding template id as one of the parameter
  - Each msg template have unique template id in service provider, this template id stored in   message_template yml

##2021-03-07
 - OTP mailer for bank payment request credit action introduced.


## 2021-03-12
  - Adding master.key to git ignore
  - Updating token based authentication
  - Correcting google auth name
  - Adding featurefliper for google auth, adding user expiration

## 2021-03-11
  - Updating sso config api
  - Updating the redirect path
  - Updating the sso based on the token recieved from fe.

## 2021-03-10
  - Updating sso path

## 2021-03-09
  - Updating error message
  - Removing reviewer change validation 
  - fixing invoice item 500 issue

## 2021-03-08
  - SMP service api updated, by adding template id as one of the parameter
  - Each msg template have unique template id in service provider, this template id stored in message_template yml

## 2021-03-07
  - OTP mailer for bank payment request credit action introduced.
  - Updating the bbps status checker credit checks.
  - Addition of success message in bbps status checker for successful payment.

## 2021-03-06
  - reverse merging the master with bug/invoice_amount_rate_validation
  - Adding validation for line item rate greater than 0

## 2021-03-05
  - Added support for overriding security policy on a company level via feature flipper
  - Added support for restricting IPs for a company
  - Added support for caching user flags
  - Added DSL support for swiggy release
  - fix: Header vs line item rule logic
  - Message service sender name changed from FINLYX to IFINLY
  - Initial changes for omni_auth

## 2021-03-04
  - Add index to statements finly_account
  - Reduce the number of columns in payments index as it was having a very slow response time
  - AutoComplete Vendors > Remove bank account search. It was slowing down the response

## 2021-03-02
  - Adding erp sync details for payment, user, and purchase_order exposure

## 2021-02-26
  - Fix: Fiscal Year ending and starting date calculation logic changed
  - Fix: Expense Rule with deleted category removed from rendering logic
  - Fix: Revised Agreement owner setting as current_user

## 2020-02-25
  - Added Inward document export in receive history screen

## 2021-02-24
  - Fix: Added `item_number` field to InvoiceLineItemExposure to support for exporting it in line items export.

## 2021-02-23
  - Updating the bbps status checker credit checks.
  - Addition of success message in bbps status checker for successful payment.

## 2020-02-22
 Adding bbps error message on failure.

### Added
  - `commit-msg` git hook to check branch name and commit message conventions.
  - `changelog.md` file to track the changes in the repo.
