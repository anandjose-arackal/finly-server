class AddLinkForSplitExpenses < ActiveRecord::Migration[4.2]
  def change
    add_column :expenses, :split_link, :string, index: true
  end
end
