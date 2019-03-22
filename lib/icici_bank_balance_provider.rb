class IciciBankBalanceProvider
  include Sidekiq::Worker
  sidekiq_options queue: :payments_critical_queue

  def perform(response_handle, company_id)
    queue = Struct.new(:queue).new(response_handle)
    begin
      company = Company.find_by_id(company_id)
      if company.blank?
        # Respond failure
        Resque.enqueue(queue, {success: false, message: 'Company not found'})
        return
      end
      user = company.users.first
      if user.blank?
        # Respond failure
        Resque.enqueue(queue, {success: false, message: 'Company not found'})
        return
      end
      # insert operation that fetches the balance for this particular account
      op = IciciBankApi::Balance.(company)
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