class AddActiveToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :active, :boolean, default: true
  end
end
