require 'yaml'
require 'money'
require 'money/bank/open_exchange_rates_bank'


Money::Bank::OpenExchangeRatesBank.module_eval do
  def exchange_rates
    {
      "AED"=>3.673045, "AFN"=>86.057585, "ALL"=>90.915171, "AMD"=>390.09416,
      "ANG"=>1.801571, "AOA"=>823.894, "ARS"=>266.765319, "AUD"=>1.467211,
      "AWG"=>1.8025, "AZN"=>1.7, "BAM"=>1.740732, "BBD"=>2, "BDT"=>108.753486,
      "BGN"=>1.739595, "BHD"=>0.376938, "BIF"=>2828.25067, "BMD"=>1, "BND"=>1.320457,
      "BOB"=>6.907416, "BRL"=>4.8073, "BSD"=>1, "BTC"=>3.3329389e-05, "BTN"=>82.007616,
      "BWP"=>13.110231, "BYN"=>2.523163, "BZD"=>2.014953, "CAD"=>1.320306,
      "CDF"=>2487.111421, "CHF"=>0.857745, "CLF"=>0.029668, "CLP"=>818.39,
      "CNH"=>7.18017, "CNY"=>7.1735, "COP"=>4049.726396, "CRC"=>540.150912, "CUC"=>1,
      "CUP"=>25.75, "CVE"=>98.135352, "CZK"=>21.0993, "DJF"=>177.72, "DKK"=>6.61864,
      "DOP"=>55.955322, "DZD"=>134.328628, "EGP"=>30.8954, "ERN"=>15, "ETB"=>55.02757,
      "EUR"=>0.888274, "FJD"=>2.19305, "FKP"=>0.761946, "GBP"=>0.761946, "GEL"=>2.567746,
      "GGP"=>0.761946, "GHS"=>11.370847, "GIP"=>0.761946, "GMD"=>59.630001, "GNF"=>8594.292266,
      "GTQ"=>7.844603, "GYD"=>209.136079, "HKD"=>7.810981, "HNL"=>24.605046, "HRK"=>6.69447,
      "HTG"=>138.952455, "HUF"=>332.311496, "IDR"=>14989.987556, "ILS"=>3.635595,
      "IMP"=>0.761946, "INR"=>82.031313, "IQD"=>1309.511862, "IRR"=>42009.1, "ISK"=>129.96,
      "JEP"=>0.761946, "JMD"=>154.574651, "JOD"=>0.7088, "JPY"=>138.271, "KES"=>141.6,
      "KGS"=>87.87, "KHR"=>4129.740608, "KMF"=>437.534485, "KPW"=>900, "KRW"=>1260.795388,
      "KWD"=>0.306226, "KYD"=>0.833074, "KZT"=>444.742117, "LAK"=>19145.084508,
      "LBP"=>15005.004124, "LKR"=>322.397657, "LRD"=>183.652, "LSL"=>18.031863, "LYD"=>4.750123,
      "MAD"=>9.714339, "MDL"=>18.050626, "MGA"=>4475.903971, "MKD"=>54.730942, "MMK"=>2099.238062,
      "MNT"=>3519, "MOP"=>8.045213, "MRU"=>35.685047, "MUR"=>45.25, "MVR"=>15.404001,
      "MWK"=>1053.690977, "MXN"=>16.7383, "MYR"=>4.5425, "MZN"=>63.830001, "NAD"=>18.02903,
      "NGN"=>775.5, "NIO"=>36.562684, "NOK"=>10.057625, "NPR"=>131.212408, "NZD"=>1.588629,
      "OMR"=>0.385017, "PAB"=>1, "PEN"=>3.558374, "PGK"=>3.573495, "PHP"=>54.402498,
      "PKR"=>275.895682, "PLN"=>3.95367, "PYG"=>7273.49291, "QAR"=>3.643185, "RON"=>4.3864,
      "RSD"=>104.115, "RUB"=>90.662501, "RWF"=>1167.103358, "SAR"=>3.752076, "SBD"=>8.36879,
      "SCR"=>13.13357, "SDG"=>601.5, "SEK"=>10.194633, "SGD"=>1.320949, "SHP"=>0.761946,
      "SLL"=>17665, "SOS"=>569.254634, "SRD"=>37.7315, "SSP"=>130.26, "STD"=>22823.990504,
      "STN"=>21.805883, "SVC"=>8.747274, "SYP"=>2512.53, "SZL"=>18.02768, "THB"=>34.1805, 
      "TJS"=>10.93614, "TMT"=>3.5, "TND"=>3.04242, "TOP"=>2.329856, "TRY"=>26.9183,
      "TTD"=>6.780144, "TWD"=>30.9655, "TZS"=>2434.16, "UAH"=>36.738376, "UGX"=>3663.38144,
      "USD"=>1, "UYU"=>38.051067, "UZS"=>11584.79607, "VES"=>28.420055, "VND"=>23643.459647,
      "VUV"=>118.979, "WST"=>2.72551, "XAF"=>582.669428, "XAG"=>0.04014621, "XAU"=>0.00050944,
      "XCD"=>2.70255, "XDR"=>0.738018, "XOF"=>582.669428, "XPD"=>0.0007715, "XPF"=>105.999262,
      "XPT"=>0.00101449, "YER"=>250.198, "ZAR"=>17.897334, "ZMW"=>18.863004, "ZWL"=>322
    }
  end
end

unless File.exists?("#{Rails.root}/config/open_exchange_rates.yml")
  raise 'config/open_exchange_rates.yml not found'
end

OPEN_EXCHANGE_RATES = YAML.load_file("#{Rails.root}/config/open_exchange_rates.yml")

LATEST_EXCHANGE_RATES = Money::Bank::OpenExchangeRatesBank.new
LATEST_EXCHANGE_RATES.app_id = OPEN_EXCHANGE_RATES['app_id']
LATEST_EXCHANGE_RATES.ttl_in_seconds = 3600

redis_config = Rails.application.config_for(:redis_config)&.with_indifferent_access
redis_creds = redis_config&.slice('url', 'password')
redis = Redis.new(redis_creds)
OXR_CACHE_KEY = 'money:open_exchange_rates'.freeze

LATEST_EXCHANGE_RATES.cache = Proc.new do |text|
  if text
    redis.set(OXR_CACHE_KEY, text)
    redis.expire(OXR_CACHE_KEY, 3600)
  else
    redis.get(OXR_CACHE_KEY)
  end
end
LATEST_EXCHANGE_RATES.update_rates
