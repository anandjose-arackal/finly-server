class YesBankBalanceProvider
  include Sidekiq::Worker
  sidekiq_options queue: :yes_bank_balance_queue

  # LOGGER = Logger.new(STDOUT)

  def perform(response_handle, company_id)
    queue = Struct.new(:queue).new(response_handle)
    begin
      company = Company.find_by_id(company_id)
      if company.blank?
        # Respond failure
        Resque.enqueue(queue, {success: false, message: 'Company not found'})
        return
      end
      op = YesBankApi::Balance::GetBalance.(company)
      # return the balance given by the API
      if op.success?
        balance = op.balance&.to_d
        Resque.enqueue(queue, {success: true, balance: balance})
      else
        Resque.enqueue(queue, {success: false, balance: 0, messages: op.messages[:error]})
      end
    rescue Exception => e
      Resque.enqueue(queue, {success: false, balance: 0, messages: e.message})
    end
  end

end