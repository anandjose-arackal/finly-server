class UpdatePrItemCostCenter < ActiveRecord::Migration[5.2]
  def change
    PurchaseRequest.where(cost_allocation_items: false).each do |pr|
      if pr.purchase_request_items.pluck(:cost_center_id).compact.blank?
        pr.purchase_request_items.update_all(cost_center_id: pr.cost_center_id)
      end
    end
  end
end
