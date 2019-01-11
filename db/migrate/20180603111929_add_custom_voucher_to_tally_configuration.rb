class AddCustomVoucherToTallyConfiguration < ActiveRecord::Migration[4.2]
  def change
    add_column :tally_configurations, :custom_voucher, :boolean, default: false
  end
end
