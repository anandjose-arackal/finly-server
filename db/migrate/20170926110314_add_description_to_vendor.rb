class AddDescriptionToVendor < ActiveRecord::Migration[4.2]
  def change
    add_column :yes_bank_vendors, :description, :string
    add_column :bank_accounts, :default_account, :boolean, default: false

  #   Setting one default account for all users and vendors
    User.all.each do |user|
      user.bank_accounts.first&.update(default_account: true)
    end

    YesBankVendor.all.each do |vendor|
      vendor.bank_accounts.first&.update(default_account: true)
    end
  end
end
