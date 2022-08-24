class ChangeSelectedToInteger < ActiveRecord::Migration[6.0]
  def change
    change_column :quotations, :selected, :integer
  end
end
