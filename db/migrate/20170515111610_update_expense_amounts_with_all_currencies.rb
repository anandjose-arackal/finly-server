class UpdateExpenseAmountsWithAllCurrencies < ActiveRecord::Migration
  def change
    # adding all 169 currencies to the conversion table
    %w(AED AFN ALL AMD ANG AOA ARS AWG AZN BAM BBD BDT BHD BIF BMD BND BOB BSD BTC BTN BWP BYN BYR BZD CDF CLF CLP COP CRC CUC CUP CVE DJF DOP DZD EEK EGP ERN
      ETB FJD FKP GEL GGP GHS GIP GMD GNF GTQ GYD HNL HTG IMP IQD IRR ISK JEP JMD JOD KES KGS KHR KMF KPW KWD KYD KZT LAK LBP LKR LRD LSL LTL LVL LYD MAD MDL MGA MKD
      MMK MNT MOP MRO MUR MVR MWK MZN NAD NGN NIO NPR OMR PAB PEN PGK PKR PYG QAR RSD RWF SAR SBD SCR SDG SHP SLL SOS SRD STD SVC SYP SZL TJS TMT TND TOP TTD TWD TZS
      UAH UGX UYU UZS VEF VND VUV WST XAF XAG XAU XCD XDR XOF XPF YER ZMK ZMW ZWL).each do |symbol|
      unless Amount.column_names.include?(symbol.to_s)
        add_column :amounts,  symbol.to_sym, :decimal, precision: 20, scale: 5
      end
    end

    # updating all created expenses to all different currencies in the amounts table
    Expense.all.each do |expense|
      date = expense.date
      rate = CurrencyConversionRate.find_by(date: date)
      update_hash = {}
      if rate.nil? || expense.amount.nil?
        next
      end
      currencies = CurrencyConversionRate.column_names.reject { |el| ['created_at', 'updated_at', 'date', 'id'].include?(el)}
      orig_curr = expense.amount.currency.country_code
      currencies.each do |curr|
        if Amount.column_names.include?(curr)
          currency_rate = rate.send(curr.to_sym).to_f
          normalized_amt = expense.amount.amount_value * currency_rate
          update_hash[curr.to_sym] = (normalized_amt/rate.send(orig_curr.to_sym))
        end
      end
      expense.amount.update(update_hash)
    end

    # seeding currencies table with all currencies
    Currency.seed_data
  end
end
