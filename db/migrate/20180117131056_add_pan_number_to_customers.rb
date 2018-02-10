class AddPanNumberToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :pan, :string
  end
end
