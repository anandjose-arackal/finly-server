class FillAmountsTableForAllAmounts < ActiveRecord::Migration
  def change
    return unless Company.count > 0
    Amount.all.each do |amount|
      amount.update(amount.currency.country_code => amount.value)
    end
  end
end
