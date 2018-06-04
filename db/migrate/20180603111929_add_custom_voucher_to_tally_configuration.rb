class AddCustomVoucherToTallyConfiguration < ActiveRecord::Migration
  def change
    add_column :tally_configurations, :custom_voucher, :boolean, default: false
  end
end
