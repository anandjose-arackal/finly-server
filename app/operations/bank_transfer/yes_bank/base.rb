class BankTransfer::YesBank::Base < BaseOperation
  attr_accessor :payment_request, :initiating_account

  def self.call(user, params)
    self.new(user, params).run
  end

  def initialize(user, params)
    super(user, params)
  end

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate

  end
  
  protected

  # this will create the respective vendors for each transaction, and create the payment request
  # for each of them - at this point, all of them will be valid
  def build_payment_request(order_data)
    self.payment_request = PaymentRequest.(user, initiating_account, BankAccount.name, :credit, :vendor_payment)
    order_data.each do |data|
      account_number = data[:bank_account_number]
      ifsc = data[:ifsc]
      name = data[:name]
      amount = data[:amount]
      vendor = YesBankVendor.create(name: name, company_id: user.company_id)
      ba = BankAccount.create(name: name, account_number: account_number, ifsc: ifsc, account_owner: vendor)
      self.payment_request.add_payment_item(PaymentRequest::PaymentItem.(vendor, ba, amount))
    end
    payment_request
  end

end