class Invoicing::Customer::CustomerAccount::Create < Invoicing::Customer::CustomerAccount::Base

  attr_accessor :customer, :customer_account, :customer_account_params

  def init
    id = params[:id] || params[:customer_id]
    self.customer = user.company.customers.find_by(id: id)

    # currency_id = customer.currency_id || 1
    currency_id = 1 # todo get customer id from customer model
    self.customer_account_params = ActionController::Parameters.new({
                                                                      customer_id: customer.id,
                                                                      balance_attributes: {
                                                                          value: 0, currency_id: currency_id
                                                                      }
                                                                    })
    self.customer_account_params.permit!
  end

  def validate
    if self.customer.blank?
      add_message :error, "Customer not found"
    end

    if customer.customer_account
      add_message :error, "Customer Already has an account"
    end
  end

  def process
    self.customer_account = CustomerAccount.new(customer_account_params)
    unless self.customer_account.save
      add_message :error, self.customer_account.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Customer account created!"
  end
end