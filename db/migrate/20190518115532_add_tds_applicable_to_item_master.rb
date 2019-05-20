class AddTdsApplicableToItemMaster < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :tds_applicable, :boolean, default: true
  end
end