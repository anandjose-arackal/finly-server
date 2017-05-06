class AddTypeOfDetailsToCardTransactions < ActiveRecord::Migration
  def change
    add_column :card_transactions, :type_of_details, :string
  end
end
