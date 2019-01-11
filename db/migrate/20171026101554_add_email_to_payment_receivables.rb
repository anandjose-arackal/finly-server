class AddEmailToPaymentReceivables < ActiveRecord::Migration[4.2]
  def change
    add_column :payment_receivables, :email, :string
  end
end
