class IciciBankStatusCheckerBackground

  include Sidekiq::Worker
  sidekiq_options queue: :payments_critical_queue

  def perform(response_handle, company_id)
    error_logger = Logger.new("#{Rails.root}/log/whenever/icici_bank_status_checker_errors.log")
    queue = Struct.new(:queue).new(response_handle)
    begin
      pending_transactions = IciciBankTransaction.processing_transactions
      pending_transactions.each do |bank_transaction|
        BankTransfer::Icici::Transactions::CheckStatus.(bank_transaction)
      end
    rescue Exception => error
      error.backtrace.each do |line|
        error_logger.error "\t #{line}"
      end
      Resque.enqueue(queue, {success: false, balance: 0, messages: error.message})
    end
  end
end