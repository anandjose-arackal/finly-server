class AddColumnsToPurchaseRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_requests, :location_id, :integer, references: "BranchLocation", foreign_key: true, index: true
    add_column :purchase_requests, :department_id, :integer, references: "Department", foreign_key: true, index: true
    add_column :purchase_requests, :policy_id, :integer, references: "Policy", foreign_key: true, index: true
    add_column :purchase_requests, :controlling_level_id, :integer, references: "ReviewalLevel", foreign_key: true, index: true
    add_column :purchase_requests, :company_id, :integer, references: "Company", foreign_key: true, index: true
  end
end
