class UpdateProcurementIdsForAllBudgetTrails < ActiveRecord::Migration
  def change
    budget_trails = BudgetTrail.where(entity_type: "PurchaseOrderItem")
    budget_trails.each do |budget_trail|
      proc = budget_trail.entity.purchase_order.procurement
      budget_trail.update(procurement_id: proc&.id)
    end
  end
end