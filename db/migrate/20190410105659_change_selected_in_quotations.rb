class ChangeSelectedInQuotations < ActiveRecord::Migration[5.2]
  def change
  	change_column :quotations, :selected, :boolean, default: false
  end
end
