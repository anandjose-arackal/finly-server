class AddConversionRatesForEverydayBeforeDeploy < ActiveRecord::Migration[4.2]
  def change
    # adding all 169 currencies to the conversion table
    %w(AED AFN ALL AMD ANG AOA ARS AWG AZN BAM BBD BDT BHD BIF BMD BND BOB BSD BTC BTN BWP BYN BYR BZD CDF CLF CLP COP CRC CUC CUP CVE DJF DOP DZD EEK EGP ERN
      ETB FJD FKP GEL GGP GHS GIP GMD GNF GTQ GYD HNL HTG IMP IQD IRR ISK JEP JMD JOD KES KGS KHR KMF KPW KWD KYD KZT LAK LBP LKR LRD LSL LTL LVL LYD MAD MDL MGA MKD
      MMK MNT MOP MRO MUR MVR MWK MZN NAD NGN NIO NPR OMR PAB PEN PGK PKR PYG QAR RSD RWF SAR SBD SCR SDG SHP SLL SOS SRD STD SVC SYP SZL TJS TMT TND TOP TTD TWD TZS
      UAH UGX UYU UZS VEF VND VUV WST XAF XAG XAU XCD XDR XOF XPF YER ZMK ZMW ZWL).each do |symbol|
      add_column :currency_conversion_rates,  symbol.to_sym, :decimal, precision: 10, scale: 5
    end

    # now storing all data for conversion from 1st April to date of deploy
    date = DateUtils.yesterday_local_date
    if Rails.env.production?
      end_date = Date.parse('01-01-2017')
    else
      end_date = 10.days.ago
    end
    while date >= end_date
      params = {
          date: date.strftime("%Y-%m-%d")
      }
      @result = Currency::FetchData.(nil, params)
      CurrencyConversionRate.create(@result.currency_data)
      date -= 1 # i.e. reducing the date by one
    end
  end
end
