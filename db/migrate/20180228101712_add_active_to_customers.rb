class AddActiveToCustomers < ActiveRecord::Migration[4.2]
  def change
    add_column :customers, :active, :boolean, default: true
  end
end
