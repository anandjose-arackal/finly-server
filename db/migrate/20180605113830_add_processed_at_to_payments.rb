class AddProcessedAtToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :processed_at, :date
  end
end
