class AddEmailPurchaseOrderInitiatorToCompanyConfigurations < ActiveRecord::Migration[5.2]
  def change
    add_column :company_configurations, :email_purchase_order_initiator, :boolean
  end
end
