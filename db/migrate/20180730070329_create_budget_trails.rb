class CreateBudgetTrails < ActiveRecord::Migration[4.2]
  def change
    create_table :budget_trails do |t|
      t.references :entity, polymorphic: true
      t.integer :category_id, references: "Category"
      t.integer :cost_center_id, references: "CostCenter"
      t.integer :location_id, references: "BranchLocation"
      t.integer :vendor_id, references: "YesBankVendor"
      t.references :amount


      t.timestamps null: false
    end
  end
end
