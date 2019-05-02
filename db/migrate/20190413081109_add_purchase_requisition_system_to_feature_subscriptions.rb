class AddPurchaseRequisitionSystemToFeatureSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :feature_subscriptions, :purchase_requisition_system, :boolean
  end
end
