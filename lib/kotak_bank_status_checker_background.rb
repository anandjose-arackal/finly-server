class KotakBankStatusCheckerBackground

  include Sidekiq::Worker
  sidekiq_options queue: :payments_critical_queue

  def perform(response_handle, company_id)
    error_logger = Logger.new("#{Rails.root}/log/whenever/kotak_bank_status_checker_errors.log")
    queue = Struct.new(:queue).new(response_handle)
    begin
      bank_transactions = KotakBankTransaction.without_utr.status_check_required

      bank_transactions.each do |bank_transaction|
        parameters = {
            unique_reference_number: bank_transaction.unique_reference_number,
            company_id: bank_transaction.company_id,
            bank_transaction: bank_transaction
        }
        op = KotakBankApi::TransactionStatus.(parameters)
        unless op.success?
          error_logger.error("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
          error_logger.error(op.messages)
          error_logger.error("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
        end
      end
    rescue Exception => error
      error.backtrace.each do |line|
        error_logger.error "\t #{line}"
      end
      Resque.enqueue(queue, {success: false, balance: 0, messages: error.message})
    end
  end
end