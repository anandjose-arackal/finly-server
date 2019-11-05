# this will be the generic trails contract that will pick up the has from the operation
# and validate it against a particular BudgetTrail model.

class BudgetManager::BudgetTrails::Contracts::Base < Reform::Form


  properties :entity_id, :entity_type, :date, :entity_status_id, presence: true
  properties :location_id, :department_id, :cost_center_id, :vendor_id, :category_id, :user_id, :procurement_id


end