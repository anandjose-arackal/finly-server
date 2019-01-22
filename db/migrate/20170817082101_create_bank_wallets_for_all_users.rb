class CreateBankWalletsForAllUsers < ActiveRecord::Migration[4.2]
  def change
    User.all.each do |user|
      user.build_bank_wallet(balance_attributes: {value: 0, currency_id: Currency.first.id}).save
    end
  end
end
