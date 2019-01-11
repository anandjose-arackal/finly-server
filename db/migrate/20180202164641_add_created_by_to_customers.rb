class AddCreatedByToCustomers < ActiveRecord::Migration[4.2]
  def change
    add_column :customers, :created_by_id, :integer, references: "User", foreign_key: true, index: true
  end
end
