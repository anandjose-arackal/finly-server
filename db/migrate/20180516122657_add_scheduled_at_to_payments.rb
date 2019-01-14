class AddScheduledAtToPayments < ActiveRecord::Migration[4.2]
  def change
    add_column :payments, :scheduled_at, :date
  end
end