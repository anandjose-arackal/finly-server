class AddTransferModeToCompanyFundsAutoTransferConfig < ActiveRecord::Migration[4.2]
  def change
    add_column :company_funds_auto_transfer_configs, :transfer_mode, :string
  end
end
