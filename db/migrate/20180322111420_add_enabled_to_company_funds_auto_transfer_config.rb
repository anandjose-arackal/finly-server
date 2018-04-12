class AddEnabledToCompanyFundsAutoTransferConfig < ActiveRecord::Migration
  def change
    add_column :company_funds_auto_transfer_configs, :enabled, :boolean, index: true, default: false
  end
end
