class AddTicketTypeToBankPaymentRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :bank_payment_requests, :ticket_type, :string
    add_index :bank_payment_requests, :ticket_type
  end
end
