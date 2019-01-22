class AddCreatedByToMainModels < ActiveRecord::Migration[4.2]
  def change
    add_column :expenses, :created_by_id, :integer, references: "User", foreign_key: true, index: true
    add_column :reports, :created_by_id, :integer, references: "User", foreign_key: true, index: true
    add_column :money_requests, :created_by_id, :integer, references: "User", foreign_key: true, index: true
    add_column :receipts, :created_by_id, :integer, references: "User", foreign_key: true, index: true
  end
end