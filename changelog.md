# Changelog

All notable changes to this project will be documented in this file. Always add new logs to 
beginning of this file.

## 2021-03-12
  - Adding master.key to git ignore
  - Updating token based authentication
  - Correcting google auth name

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
