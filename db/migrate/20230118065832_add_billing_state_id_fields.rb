class AddBillingStateIdFields < ActiveRecord::Migration[6.0]
  def change
    unless column_exists?(:invoices, :vendor_state_id)
      add_column :invoices, :vendor_state_id, :integer
    end

    unless column_exists?(:invoices, :billing_state_id)
      add_column :invoices, :billing_state_id, :integer
    end

    unless column_exists?(:purchase_orders, :vendor_state_id)
      add_column :purchase_orders, :vendor_state_id, :integer
    end

    unless column_exists?(:purchase_orders, :billing_state_id)
      add_column :purchase_orders, :billing_state_id, :integer
    end
  end
end
