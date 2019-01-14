class AddCashOnHandForAllUsers < ActiveRecord::Migration[4.2]
  def change
    User.all.each do |u|
      cih = u.cash_in_hand
      u.build_cash_on_hand(balance: cih).save
    end
  end
end
