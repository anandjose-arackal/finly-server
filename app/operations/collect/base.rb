class Collect::Base < BackgroundOperation

  attr_accessor :virtual_account_transaction, :options, :virtual_account

  def self.call(virtual_account_transaction_id, options = {})
    self.virtual_account_transaction = ::VirtualAccountTransaction.find_by(id: virtual_account_transaction_id)
    self.new(virtual_account_transaction, options).run
  end

  def self.call_async(virtual_account_transaction_id, options = {})
    # define the operation to accordingly run the operation in the background
    self.perform_async(virtual_account_transaction_id, options)
  end

  def perform(virtual_account_transaction_id, options)
    if options.present? and options.is_a?(Hash)
      options = options.with_indifferent_access
    end
    self.virtual_account_transaction = ::VirtualAccountTransaction.find_by(id: virtual_account_transaction_id)
    self.options = options
    self.run
  end

  def perform_async(virtual_account_transaction_id, options)
    # in case the object is passed directly instead of an id
    virtual_account_transaction_id = virtual_account_transaction_id
    if virtual_account_transaction_id.present? && virtual_account_transaction_id.is_a?(::VirtualAccountTransaction)
      virtual_account_transaction_id = virtual_account_transaction_id.id
    end
    # calls the Sidekiq::Worker method
    super(virtual_account_transaction_id, options)
  end

  def initialize
    # super()
    # self.virtual_account_transaction = virtual_account_transaction
    # self.options = options
  end

  # def init_payment_request(purpose, company)
  #   # todo - initiating resource to be finished
  #   initiating_account = self.virtual_account
  #   initiating_user = self.virtual_account.initiating_user
  #   payment_request = PaymentRequest.(initiating_user, initiating_account, company.yes_bank_company_account.class.name, :credit, :virtual_account_credit)
  #   payment_request.add_payment_item(PaymentRequest::PaymentItem.(nil, company.yes_bank_company_account, self.virtual_account_transaction.transfer_amount))
  #   payment_request
  # end

  
end