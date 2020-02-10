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
Crono.perform(FixSpuriousPayments).every 1.day, at: {hour: 06, min: 30}
Crono.perform(CheckForFailedNeftTransactions).every 1.hour
# Crono.perform(AdminPanelVerifierMailer).every 1.hour
Crono.perform(YesBankStatusChecker).every 15.minutes
Crono.perform(IciciStatusChecker).every 15.minutes
# Crono.perform(BackupImages).every 1.day, at: {hour: 01, min: 00}
# Summary mailer checks performed every 30minutes
24.times do |num|
  Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: num, min: 00}
  Crono.perform(SummaryMailersProcessor).every 1.day, at: {hour: num, min: 30}
end
Crono.perform(ReminderOutwardInvoices).every 1.day, at: {hour: 9, min: 30}
Crono.perform(CompanyAccountScheduledTransfer).every 1.day, at: {hour: 9, min: 30}
Crono.perform(BankTransferProcessRetry).every 30.minutes
Crono.perform(BalanceTallyLedgerProcess).every 1.day, at: {hour: 23, min: 30}
Crono.perform(IciciStatementsFetch).every 30.minutes
Crono.perform(KotakBankTransferStatusChecker).every 5.minutes
Crono.perform(BbpsBillsFetch).every 1.day, at: {hour: 8, min: 00}

# Always scope scheduled mailers to production env to avoid accidental email trigger via development/staging environment
# if Rails.env.production?
#    Crono.perform(ReportsAwaitingApproval).every 1.day, at: {hour: 18, min: 00}
# end
# Crono.perform(ReminderAwaitingApproval).every 1.day, at: {hour: 10, min: 00}
Crono.perform(ReminderAwaitingApproval).every 1.day, at: {hour: 18, min: 00}
# Crono.perform(ReminderSubmitPending).every 1.day, at: {hour: 10, min: 00}
# Crono.perform(ReminderSubmitPending).every 1.day, at: {hour: 17, min: 00}
Crono.perform(ExpenseStatusUpdate).every 30.minutes

# status checker for BBPS Bill Payments
Crono.perform(BbpsBillStatusChecker).every 30.minutes

Crono.perform(BbpsBillerSync).every 1.day, at: {hour: 12, min: 10}