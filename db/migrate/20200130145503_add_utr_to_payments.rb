class AddUtrToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :utr, :string, index: true
  end
end
