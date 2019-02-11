class AddEnabledToCompanyFundsAutoTransferConfig < ActiveRecord::Migration[4.2]
  def change
    add_column :company_funds_auto_transfer_configs, :enabled, :boolean, index: true, default: false
  end
end
