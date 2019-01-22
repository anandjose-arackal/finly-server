class AddPanNumberToCustomers < ActiveRecord::Migration[4.2]
  def change
    add_column :customers, :pan, :string
  end
end
