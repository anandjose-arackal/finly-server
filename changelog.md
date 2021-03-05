# Changelog

All notable changes to this project will be documented in this file. Always add new logs to beginning of this file.

Updating the bbps status checker credit checks.
Addition of success message in bbps status checker for successful payment.

## 2020-02-25
- Added Inward document export in receive history screen

Adding bbps error message on failure.
## 2020-02-26
 - Fix: Fiscal Year ending and starting date calculation logic changed
 - Fix: Expense Rule with deleted category removed from rendering logic
 - Fix: Revised Agreement owner setting as current_user

## 2020-02-24
 - Fix: Added `item_number` field to InvoiceLineItemExposure to support for exporting it in line items export.

## 2020-02-23
 - Updating the bbps status checker credit checks.
 - Addition of success message in bbps status checker for successful payment.

## 2020-02-22

## 2020-03-02
 - Adding erp sync details for payment, user, and purchase_order exposure

## 2020-03-04
- Add index to statements finly_account
- Reduce the number of columns in payments index as it was having a very slow response time
- AutoComplete Vendors > Remove bank account search. It was slowing down the response

## 2020-03-05
- Added support for overriding security policy on a company level via feature flipper
- Added support for restricting IPs for a company
- Added support for caching user flags

### Added

- `commit-msg` git hook to check branch name and commit message conventions.
- `changelog.md` file to track the changes in the repo.
