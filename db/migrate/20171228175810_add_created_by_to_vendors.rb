class AddCreatedByToVendors < ActiveRecord::Migration
  def change
    add_column :yes_bank_vendors, :created_by_id, :integer, references: "User", foreign_key: true, index: true
  end
end
