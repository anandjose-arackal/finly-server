class AddBprVoucherToTallyConfig < ActiveRecord::Migration[5.2]
  def change
    add_column :tally_configurations, :bpr_voucher_enabled, :boolean
    add_column :tally_configurations, :bpr_voucher_configuration, :text, limit: 4294967295
  end
end
