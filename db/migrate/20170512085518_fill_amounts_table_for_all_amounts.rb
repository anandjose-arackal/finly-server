class FillAmountsTableForAllAmounts < ActiveRecord::Migration[4.2]
  def change
    return unless Company.count > 0
    Amount.all.each do |amount|
      amount.update(amount.currency.country_code => amount.value)
    end
  end
end
