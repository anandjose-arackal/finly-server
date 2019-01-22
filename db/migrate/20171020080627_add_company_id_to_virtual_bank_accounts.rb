class AddCompanyIdToVirtualBankAccounts < ActiveRecord::Migration[4.2]
  def change
    VirtualAccountPurpose.seed_data
  end
end
