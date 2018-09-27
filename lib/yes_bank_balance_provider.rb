class YesBankBalanceProvider
  include Sidekiq::Worker

  LOGGER = Logger.new(STDOUT)

  def perform(response_handle, company_id)
    begin
    company = Company.find_by_id(company_id)
    if company.blank?
      # Respond failure
      Resque.enqueue(response_handle, {success: false, message: 'Company not found'})
      return
    end
    user = company.users.first
    if user.blank?
      # Respond failure
      Resque.enqueue(response_handle, {success: false, message: 'Company not found'})
      return
    end
    op = YesBankApi::Balance::GetBalance.(company)
    # return the balance given by the API
    if op.success?
      balance = op.balance&.to_d
      Resque.enqueue(response_handle, {success: true, balance: balance})
    else
      Resque.enqueue(response_handle, {success: false, balance: 0, messages: op.messages[:error]})
    end
    rescue Exception => e
      Resque.enqueue(response_handle, {success: false, balance: 0, messages: e.message})
    end
  end

end