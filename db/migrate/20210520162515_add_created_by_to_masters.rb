class AddCreatedByToMasters < ActiveRecord::Migration[6.0]

  def change
    add_column :branch_locations, :created_by_id, :integer, references: "User", foreign_key: true, index: true
    add_column :cost_centers, :created_by_id, :integer, references: "User", foreign_key: true, index: true
    add_column :departments, :created_by_id, :integer, references: "User", foreign_key: true, index: true
    add_column :items, :created_by_id, :integer, references: "User", foreign_key: true, index: true
    add_column :payment_terms, :created_by_id, :integer, references: "User", foreign_key: true, index: true

  end
end
