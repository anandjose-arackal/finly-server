class AddVendorEmpanelmentToFeature < ActiveRecord::Migration[5.2]
  def change
    add_column :feature_subscriptions, :vendor_empanelment_workflow, :boolean, default: false
  end
end
