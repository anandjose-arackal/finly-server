class FillAmountsTableForAllAmounts < ActiveRecord::Migration
  def change
    Amount.all.each do |amount|
      amount.update(amount.currency.country_code => amount.value)
    end
  end
end
