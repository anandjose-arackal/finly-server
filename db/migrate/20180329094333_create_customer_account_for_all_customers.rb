class CreateCustomerAccountForAllCustomers < ActiveRecord::Migration
  def change
    customers = Customer.all
    for customer in customers
      next if customer.customer_account.is_a?(CustomerAccount)
      ca = CustomerAccount.new({
                                   customer_id: customer.id,
                                   balance_attributes: {
                                       value: 0, currency_id: 1
                                   }
                               })
      ca.save
    end
  end
end
