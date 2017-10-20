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
Crono.perform(UpdateUserBalances).every 1.day, at: {hour: 00, min: 10}
Crono.perform(UpdateCompanyBalances).every 1.day, at: {hour: 00, min: 20}
Crono.perform(TaxBenefitProcess).every 1.day, at: {hour: 00, min: 25}
Crono.perform(BankTransferProcess).every 1.day, at: {hour: 9, min: 25}
Crono.perform(FetchCurrencyConversionRates).every 1.day, at: {hour: 05, min: 35}
Crono.perform(UpdateConvertedAmountValues).every 1.day, at: {hour: 05, min: 40}
# Crono.perform(AdminPanelVerifierMailer).every 1.hour
Crono.perform(BankTransferStatusChecker).every 1.hour
Crono.perform(BackupImages).every 1.day, at: {hour: 01, min: 00}

# Summary mailer checks performed every 30minutes
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 00, min: 00}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 00, min: 30}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 1, min: 00}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 1, min: 30}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 2, min: 00}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 2, min: 30}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 3, min: 00}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 3, min: 30}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 4, min: 00}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 4, min: 30}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 5, min: 00}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 5, min: 30}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 6, min: 00}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 6, min: 30}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 7, min: 00}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 7, min: 30}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 8, min: 00}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 8, min: 30}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 9, min: 00}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 9, min: 30}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 10, min: 00}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 10, min: 30}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 11, min: 00}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 11, min: 30}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 12, min: 00}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 12, min: 30}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 13, min: 00}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 13, min: 30}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 14, min: 00}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 14, min: 30}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 15, min: 00}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 15, min: 30}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 16, min: 00}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 16, min: 30}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 17, min: 00}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 17, min: 30}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 18, min: 00}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 18, min: 30}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 19, min: 00}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 19, min: 30}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 20, min: 00}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 20, min: 30}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 21, min: 00}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 21, min: 30}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 22, min: 00}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 22, min: 30}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 23, min: 00}
Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: 23, min: 30}
