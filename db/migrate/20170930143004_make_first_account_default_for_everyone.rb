class MakeFirstAccountDefaultForEveryone < ActiveRecord::Migration
  def change
    YesBankVendor.all.each do |vendor|
      vendor.bank_accounts.first&.update(default_account: true)
    end
    User.all.each do |user|
      user.bank_accounts.first&.update(default_account: true)
    end
  end
end
