# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
#

# if ['aws_production', 'foreground_production', 'api_production',
#     'background_production', 'background_production_bgg', 'background_production_bgp',
#     'background_production_bgpc', 'yes_bank_balance_poller',
#     'console_production'].include?(fetch(:stage)&.to_s)
#   load_secure_storage(:production)
# elsif ['background_production_console'].include?(fetch(:stage)&.to_s)
#   load_secure_storage(:background_production_console)
# end

env :PATH, ENV['PATH']

set :output, "#{path}/log/whenever.log"

every 30.minutes, roles: [:whenever_cron] do
  runner "YesBankStatusChecker.perform", output: "#{path}/log/whenever/yes_bank_status_checker.log"
  runner "IciciStatusChecker.perform", output: "#{path}/log/whenever/icici_status_checker.log"
  runner "KotakBankTransferStatusChecker.perform", output: "#{path}/log/whenever/kotak_status_checker.log"
  runner "BbpsBillStatusChecker.perform", output: "#{path}/log/whenever/bbps_bill_status_checker.log"
end

every 30.minutes, roles: [:whenever_cron] do
  # runner "BankTransferProcessRetry.perform", output: "#{path}/log/whenever/bank_transfer_process_retry.log"
  runner "ExpenseStatusUpdate.perform"
end

every 6.hours, roles: [:whenever_cron] do
  runner "UpdateCompanyBalances.perform"
  runner "IciciStatementsFetch.perform", output: "#{path}/log/whenever/icici_statements_fetch.log"
end

every 1.day, at: '12:01 am', roles: [:whenever_cron] do
  runner "ReportAutoSubmit.perform"
end

every 1.day, at: '8:30 am', roles: [:whenever_cron] do
  runner "TaxBenefitProcess.perform"
  runner "ScheduledBankTransferProcess.perform", output: "#{path}/log/whenever/scheduled_bank_transfer_process.log"
end

every 1.day, at: '5:35 am', roles: [:whenever_cron] do
  runner "FetchCurrencyConversionRates.perform", output: "#{path}/log/whenever/fetch_currency_conversion_rates.log"
  runner "CreateMissedCardTransactions.perform", output: "#{path}/log/whenever/card_transaction_recon.log"
end

every 1.day, at: '5:45 am', roles: [:whenever_cron] do
  runner "UpdateConvertedAmountValues.perform", output: "#{path}/log/whenever/update_converted_amount_values.log"
  runner "CheckForFailedNeftTransactions.perform", output: "#{path}/log/whenever/failed_neft_transactions_check.log"
end

every 1.day, at: '6:30 am', roles: [:whenever_cron] do
  runner "FixSpuriousPayments.perform"
end

every :hour, roles: [:whenever_cron] do
  runner "SummaryMailersProcessor.perform"
end

every 1.day, at: "9:30 am", roles: [:whenever_cron] do
  runner "ReminderOutwardInvoices.perform"
  runner "CompanyAccountScheduledTransfer.perform"
end

every 1.day, at: "8:00 am", roles: [:whenever_cron] do
  runner "BbpsBillsFetch.perform", output: "#{path}/log/whenever/bbps_bill_fetch.log"
end

every 1.day, at: "6:00 pm", roles: [:whenever_cron] do
  runner "ReminderAwaitingApproval.perform"
end

every 1.day, at: "12:10 am", roles: [:whenever_cron] do
  runner "BbpsBillerSync.perform", output: "#{path}/log/whenever/bbps_biller_sync.log"
end

every 30.seconds, roles: [:whenever_cron] do
  runner 'SearchkickReindexJob.delay.perform'
end