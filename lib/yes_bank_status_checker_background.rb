class YesBankStatusCheckerBackground

  include Sidekiq::Worker
  sidekiq_options queue: :payments_critical_queue

  def perform(response_handle, company_id)
    error_logger = Logger.new("#{Rails.root}/log/whenever/yes_bank_status_checker_errors.log")
    queue = Struct.new(:queue).new(response_handle)
    begin
      pending_transactions = YesBankTransaction.processing_transactions.non_penny_test.all
      pending_transactions.find_each do |trans|
        # where all the magic happens!
        BankTransfer::YesBank::CheckStatus.(trans)
      end
    rescue Exception => error
      error.backtrace.each do |line|
        error_logger.error "\t #{line}"
      end
      Resque.enqueue(queue, {success: false, balance: 0, messages: error.message})
    end
  end
end