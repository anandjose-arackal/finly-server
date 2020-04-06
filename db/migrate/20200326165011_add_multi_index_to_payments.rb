class AddMultiIndexToPayments < ActiveRecord::Migration[5.2]
  def change
    add_index :payments, [:date, :created_at]
  end
end
