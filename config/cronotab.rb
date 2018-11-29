# cronotab.rb — Crono configuration file
#
# Here you can specify periodic jobs and schedule.
# You can use ActiveJob's jobs from `app/jobs/`
# You can use any class. The only requirement is that
# class should have a method `perform` without arguments.
#
# class TestJob
#   def perform
#     puts 'Test!'
#   end
# end
#
# Crono.perform(TestJob).every 2.days, at: '15:30'
#

Crono.perform(ReportAutoSubmit).every 1.day, at: {hour: 00, min: 1}
# Crono.perform(UpdateUserBalances).every 1.day, at: {hour: 00, min: 10}
Crono.perform(UpdateCompanyBalances).every 1.hour
Crono.perform(TaxBenefitProcess).every 1.day, at: {hour: 00, min: 25}
Crono.perform(BankTransferProcess).every 1.day, at: {hour: 9, min: 25}
Crono.perform(FetchCurrencyConversionRates).every 1.day, at: {hour: 05, min: 35}
Crono.perform(UpdateConvertedAmountValues).every 1.day, at: {hour: 05, min: 40}
# Crono.perform(AdminPanelVerifierMailer).every 1.hour
Crono.perform(BankTransferStatusChecker).every 15.minutes
# Crono.perform(BackupImages).every 1.day, at: {hour: 01, min: 00}
# Summary mailer checks performed every 30minutes
24.times do |num|
  Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: num, min: 00}
  Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: num, min: 30}
end
Crono.perform(ReminderOutwardInvoices).every 1.day, at: {hour: 9, min: 30}
Crono.perform(CompanyAccountScheduledTransfer).every 1.day, at: {hour: 9, min: 30}
Crono.perform(BankTransferProcessRetry).every 30.minutes
