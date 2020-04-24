class IciciStatementsFetchBackground

  include Sidekiq::Worker
  sidekiq_options queue: :payments_critical_queue

  def perform(response_handle, company_id)
    error_logger = Logger.new("#{Rails.root}/log/whenever/icici_statements_fetch_errors.log")
    Company.all.each do |company|
      unless company.bank_service_provider == "ICICI"
        next
      end
      begin
        op = IciciBankApi::AccountStatement.(company, {start_date: (Date.today - 15.days), end_date: Date.today})
        unless op.success?
          # todo - trigger email notifying the fact that the statement fetch failed
          error_logger.error("Company Name - #{company.name}, with ID - #{company.id} statement fetch failed because: #{error.message}")
        end
      rescue => error
        error_logger.error("Company Name - #{company.name}, with ID - #{company.id} statement fetch failed because: #{error.message}")
        error.backtrace.each do |line|
          error_logger.error "\t #{line}"
        end
      end
    end
  end

end