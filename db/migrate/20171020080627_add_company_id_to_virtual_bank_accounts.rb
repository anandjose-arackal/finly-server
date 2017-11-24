class AddCompanyIdToVirtualBankAccounts < ActiveRecord::Migration
  def change
    VirtualAccountPurpose.seed_data
  end
end
