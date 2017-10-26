class AddEmailToPaymentReceivables < ActiveRecord::Migration
  def change
    add_column :payment_receivables, :email, :string
  end
end
