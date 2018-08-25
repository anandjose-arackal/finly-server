class AddScheduledAtToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :scheduled_at, :date
  end
end