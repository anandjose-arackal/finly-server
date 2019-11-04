# this will be the generic trails contract that will pick up the has from the operation
# and validate it against a particular BudgetTrail model.

class BudgetManager::BudgetTrails::Contracts::Base < Reform::Form


  properties :entity_id, :entity_type, :amount_id, :date, :entity_status_id, presence: true


end