class MakeCustomersSoftDeletable < ActiveRecord::Migration[4.2]
  def change
    # add_column :customers, :is_deleted, :boolean, default: false
  end
end
