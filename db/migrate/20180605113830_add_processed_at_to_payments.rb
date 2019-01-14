class AddProcessedAtToPayments < ActiveRecord::Migration[4.2]
  def change
    add_column :payments, :processed_at, :date
  end
end
