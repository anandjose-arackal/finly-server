class ModifyExpensePersonalAttribute < ActiveRecord::Migration
  def change
    change_column :expenses, :personal, :boolean,default: false
    add_column :card_expenses, :atm_surcharge, :boolean, default: false
  end
end
