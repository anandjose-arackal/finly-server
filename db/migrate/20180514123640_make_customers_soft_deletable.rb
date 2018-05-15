class MakeCustomersSoftDeletable < ActiveRecord::Migration
  def change
    add_column :customers, :is_deleted, :boolean, default: false
  end
end
