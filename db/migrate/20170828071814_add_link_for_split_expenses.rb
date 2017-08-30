class AddLinkForSplitExpenses < ActiveRecord::Migration
  def change
    add_column :expenses, :split_link, :string, index: true
  end
end
