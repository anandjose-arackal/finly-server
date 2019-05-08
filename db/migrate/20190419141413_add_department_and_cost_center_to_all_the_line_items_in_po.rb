class AddDepartmentAndCostCenterToAllTheLineItemsInPo < ActiveRecord::Migration[5.2]
  def change
    PurchaseOrder.all.each do |po|
      department = po.department
      cost_center = po.cost_center
      po.items.update_all(department_id: department&.id, cost_center_id: cost_center&.id)
    end
  end
end