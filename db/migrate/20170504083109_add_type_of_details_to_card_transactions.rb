class AddTypeOfDetailsToCardTransactions < ActiveRecord::Migration[4.2]
  def change
    add_column :card_transactions, :type_of_details, :string
  end
end
