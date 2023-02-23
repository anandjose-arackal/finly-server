class AddAppliedLdcToPurchaseOrder < ActiveRecord::Migration[6.0]
  def change
    add_column :purchase_orders, :applied_ldc_id, :integer

    # Just because we have to have the db fields that we have in forms even if there's no use storing
    add_column :purchase_orders, :ldc_upper_limit_amount, :decimal, precision: 20, scale: 10
    add_column :purchase_orders, :ldc_used_amount, :decimal, precision: 20, scale: 10
    add_column :purchase_orders, :ldc_percentage, :decimal, precision: 20, scale: 10
  end
end
