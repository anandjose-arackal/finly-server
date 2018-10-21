class AddProcurementIdToBudgetTrail < ActiveRecord::Migration
  def change
    add_column :budget_trails, :procurement_id, :integer, references: "Procurement", foreign_key: true, index: true
  end
end