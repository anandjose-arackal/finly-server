# == Schema Information
#
# Table name: currencies
#
#  id           :integer          not null, primary key
#  country      :string(255)
#  country_code :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  symbol       :string(255)
#


class Currency < ActiveRecord::Base
  has_many :amounts

  # since default currency is INR
  def self.default_currency_id
    1
  end

  CURRENCIES = [
      {
          country: "India Rupee",
          country_code: "INR",
          symbol: "₹"
      },
      {
          country: "United States of America Dollar",
          country_code: "USD",
          symbol: "$"
      },
      {
          country: "United Kingdom Pound",
          country_code: "GBP",
          symbol: "£"
      },
      {
          country: "Australia Dollar",
          country_code: "AUD",
          symbol: "$"
      },
      {
          country: "Europe Euro",
          country_code: "EUR",
          symbol: "€"
      },
      {
          country: "China Yuan",
          country_code: "CNY",
          symbol: "¥"
      },
      {
          country: "Japan Yen",
          country_code: "JPY",
          symbol: "¥"
      },
      {
          country: "New Zealand Dollar",
          country_code: "NZD",
          symbol: "$"
      },
      {
          country: "Russia Ruble",
          country_code: "RUB",
          symbol: "₽"
      },
      {
          :country=>"United Arab Emirates Dirham",
          :country_code=>"AED",
          symbol: ""
      },
      {
          :country => "Afghan Afghani",
          :country_code => "AFN",
          symbol: "؋"
      },
      {
          :country => "Albanian Lek",
          :country_code => "ALL",
          symbol: "Lek"
      },
      {
          :country => "Armenian Dram",
          :country_code => "AMD",
          symbol: "դր."
      },
      {
          :country => "Netherlands Antillean Guilder",
          :country_code => "ANG",
          symbol: "ƒ"
      },
      {
          :country => "Angolan Kwanza",
          :country_code => "AOA"
      },
      {
          :country => "Argentine Peso",
          :country_code => "ARS",
          symbol: "$"
      },
      {
          :country => "Aruban Florin",
          :country_code => "AWG",
          symbol: ""
      },
      {
          :country => "Azerbaijani Manat",
          :country_code => "AZN",
          symbol: "₼"
      },
      {
          :country => "Bosnia-Herzegovina Convertible Mark",
          :country_code => "BAM",
          symbol: "KM"
      },
      {
          :country => "Barbadian Dollar",
          :country_code => "BBD",
          symbol: "$"
      },
      {
          :country => "Bangladeshi Taka",
          :country_code => "BDT"
      },
      {
          :country => "Bulgarian Lev",
          :country_code => "BGN"
      },
      {
          :country => "Bahraini Dinar",
          :country_code => "BHD"
      },
      {
          :country => "Burundian Franc",
          :country_code => "BIF"
      },
      {
          :country => "Bermudan Dollar",
          :country_code => "BMD",
          symbol: "$"
      },
      {
          :country => "Brunei Dollar",
          :country_code => "BND",
          symbol: "$"
      },
      {
          :country => "Bolivian Boliviano",
          :country_code => "BOB"
      },
      {
          :country => "Brazilian Real",
          :country_code => "BRL"
      },
      {
          :country => "Bahamian Dollar",
          :country_code => "BSD",
          symbol: "$"
      },
      {
          :country => "Bitcoin",
          :country_code => "BTC"
      },
      {
          :country => "Bhutanese Ngultrum",
          :country_code => "BTN"
      },
      {
          :country => "Botswanan Pula",
          :country_code => "BWP"
      },
      {
          :country => "Belarusian Ruble",
          :country_code => "BYN"
      },
      {
          :country => "Belize Dollar",
          :country_code => "BZD",
          symbol: "$"
      },
      {
          :country => "Canadian Dollar",
          :country_code => "CAD",
          symbol: "$"
      },
      {
          :country => "Congolese Franc",
          :country_code => "CDF"
      },
      {
          :country => "Swiss Franc",
          :country_code => "CHF"
      },
      {
          :country => "Chilean Unit of Account (UF)",
          :country_code => "CLF"
      },
      {
          :country => "Chilean Peso",
          :country_code => "CLP"
      },
      {
          :country => "Chinese Yuan (Offshore)",
          :country_code => "CNH"
      },
      {
          :country => "Colombian Peso",
          :country_code => "COP"
      },
      {
          :country => "Costa Rican Colón",
          :country_code => "CRC"
      },
      {
          :country => "Cuban Convertible Peso",
          :country_code => "CUC"
      },
      {
          :country => "Cuban Peso",
          :country_code => "CUP"
      },
      {
          :country => "Cape Verdean Escudo",
          :country_code => "CVE"
      },
      {
          :country => "Czech Republic Koruna",
          :country_code => "CZK"
      },
      {
          :country => "Djiboutian Franc",
          :country_code => "DJF"
      },
      {
          :country => "Danish Krone",
          :country_code => "DKK",
          symbol: "kr"
      },
      {
          :country => "Dominican Peso",
          :country_code => "DOP"
      },
      {
          :country => "Algerian Dinar",
          :country_code => "DZD"
      },
      {
          :country => "Egyptian Pound",
          :country_code => "EGP",
          symbol: "£"
      },
      {
          :country => "Eritrean Nakfa",
          :country_code => "ERN"
      },
      {
          :country => "Ethiopian Birr",
          :country_code => "ETB"
      },
      {
          :country => "Fijian Dollar",
          :country_code => "FJD",
          symbol: "$"
      },
      {
          :country => "Falkland Islands Pound",
          :country_code => "FKP",
          symbol: "£"
      },
      {
          :country => "Georgian Lari",
          :country_code => "GEL"
      },
      {
          :country => "Guernsey Pound",
          :country_code => "GGP",
          symbol: "£"
      },
      {
          :country => "Ghanaian Cedi",
          :country_code => "GHS"
      },
      {
          :country => "Gibraltar Pound",
          :country_code => "GIP",
          symbol: "£"
      },
      {
          :country => "Gambian Dalasi",
          :country_code => "GMD"
      },
      {
          :country => "Guinean Franc",
          :country_code => "GNF"
      },
      {
          :country => "Guatemalan Quetzal",
          :country_code => "GTQ"
      },
      {
          :country => "Guyanaese Dollar",
          :country_code => "GYD",
          symbol: "$"
      },
      {
          :country => "Hong Kong Dollar",
          :country_code => "HKD",
          symbol: "$"
      },
      {
          :country => "Honduran Lempira",
          :country_code => "HNL"
      },
      {
          :country => "Croatian Kuna",
          :country_code => "HRK"
      },
      {
          :country => "Haitian Gourde",
          :country_code => "HTG"
      },
      {
          :country => "Hungarian Forint",
          :country_code => "HUF",
          symbol: "Ft"
      },
      {
          :country => "Indonesian Rupiah",
          :country_code => "IDR",
          symbol: "Rp"
      },
      {
          :country => "Israeli New Sheqel",
          :country_code => "ILS",
          symbol: "₪"
      },
      {
          :country => "Manx pound",
          :country_code => "IMP",
          symbol: "£"
      },
      {
          :country => "Iraqi Dinar",
          :country_code => "IQD"
      },
      {
          :country => "Iranian Rial",
          :country_code => "IRR"
      },
      {
          :country => "Icelandic Króna",
          :country_code => "ISK",
          symbol: "kr"
      },
      {
          :country => "Jersey Pound",
          :country_code => "JEP",
          symbol: "£"
      },
      {
          :country => "Jamaican Dollar",
          :country_code => "JMD",
          symbol: "J$"
      },
      {
          :country => "Jordanian Dinar",
          :country_code => "JOD"
      },
      {
          :country => "Kenyan Shilling",
          :country_code => "KES"
      },
      {
          :country => "Kyrgystani Som",
          :country_code => "KGS",
          symbol: "лв"
      },
      {
          :country => "Cambodian Riel",
          :country_code => "KHR"
      },
      {
          :country => "Comorian Franc",
          :country_code => "KMF"
      },
      {
          :country => "North Korean Won",
          :country_code => "KPW",
          symbol: "₩"
      },
      {
          :country => "South Korean Won",
          :country_code => "KRW",
          symbol: "₩"
      },
      {
          :country => "Kuwaiti Dinar",
          :country_code => "KWD"
      },
      {
          :country => "Cayman Islands Dollar",
          :country_code => "KYD",
          symbol: "$"
      },
      {
          :country => "Kazakhstani Tenge",
          :country_code => "KZT",
          symbol: "лв"
      },
      {
          :country => "Laotian Kip",
          :country_code => "LAK"
      },
      {
          :country => "Lebanese Pound",
          :country_code => "LBP",
          symbol: "£"
      },
      {
          :country => "Sri Lankan Rupee",
          :country_code => "LKR",
          symbol: "Rs"
      },
      {
          :country => "Liberian Dollar",
          :country_code => "LRD",
          symbol: "$"
      },
      {
          :country => "Lesotho Loti",
          :country_code => "LSL"
      },
      {
          :country => "Libyan Dinar",
          :country_code => "LYD"
      },
      {
          :country => "Moroccan Dirham",
          :country_code => "MAD"
      },
      {
          :country => "Moldovan Leu",
          :country_code => "MDL"
      },
      {
          :country => "Malagasy Ariary",
          :country_code => "MGA"
      },
      {
          :country => "Macedonian Denar",
          :country_code => "MKD"
      },
      {
          :country => "Myanma Kyat",
          :country_code => "MMK"
      },
      {
          :country => "Mongolian Tugrik",
          :country_code => "MNT"
      },
      {
          :country => "Macanese Pataca",
          :country_code => "MOP"
      },
      {
          :country => "Mauritanian Ouguiya",
          :country_code => "MRO"
      },
      {
          :country => "Mauritian Rupee",
          :country_code => "MUR",
          symbol: "Rs"
      },
      {
          :country => "Maldivian Rufiyaa",
          :country_code => "MVR"
      },
      {
          :country => "Malawian Kwacha",
          :country_code => "MWK"
      },
      {
          :country => "Mexican Peso",
          :country_code => "MXN"
      },
      {
          :country => "Malaysian Ringgit",
          :country_code => "MYR"
      },
      {
          :country => "Mozambican Metical",
          :country_code => "MZN"
      },
      {
          :country => "Namibian Dollar",
          :country_code => "NAD",
          symbol: "$"
      },
      {
          :country => "Nigerian Naira",
          :country_code => "NGN"
      },
      {
          :country => "Nicaraguan Córdoba",
          :country_code => "NIO"
      },
      {
          :country => "Norwegian Krone",
          :country_code => "NOK",
          symbol: "kr"
      },
      {
          :country => "Nepalese Rupee",
          :country_code => "NPR",
          symbol: "Rs"
      },
      {
          :country => "Omani Rial",
          :country_code => "OMR"
      },
      {
          :country => "Panamanian Balboa",
          :country_code => "PAB"
      },
      {
          :country => "Peruvian Nuevo Sol",
          :country_code => "PEN"
      },
      {
          :country => "Papua New Guinean Kina",
          :country_code => "PGK"
      },
      {
          :country => "Philippine Peso",
          :country_code => "PHP"
      },
      {
          :country => "Pakistani Rupee",
          :country_code => "PKR",
          symbol: "Rs"
      },
      {
          :country => "Polish Zloty",
          :country_code => "PLN"
      },
      {
          :country => "Paraguayan Guarani",
          :country_code => "PYG"
      },
      {
          :country => "Qatari Rial",
          :country_code => "QAR"
      },
      {
          :country => "Romanian Leu",
          :country_code => "RON"
      },
      {
          :country => "Serbian Dinar",
          :country_code => "RSD",
          symbol: "Дин."
      },
      {
          :country => "Rwandan Franc",
          :country_code => "RWF"
      },
      {
          :country => "Saudi Riyal",
          :country_code => "SAR"
      },
      {
          :country => "Solomon Islands Dollar",
          :country_code => "SBD",
          symbol: "$"
      },
      {
          :country => "Seychellois Rupee",
          :country_code => "SCR",
          symbol: "Rs"
      },
      {
          :country => "Sudanese Pound",
          :country_code => "SDG",
          symbol: "£"
      },
      {
          :country => "Swedish Krona",
          :country_code => "SEK",
          symbol: "kr"
      },
      {
          :country => "Singapore Dollar",
          :country_code => "SGD",
          symbol: "$"
      },
      {
          :country => "Saint Helena Pound",
          :country_code => "SHP",
          symbol: "£"
      },
      {
          :country => "Sierra Leonean Leone",
          :country_code => "SLL"
      },
      {
          :country => "Somali Shilling",
          :country_code => "SOS"
      },
      {
          :country => "Surinamese Dollar",
          :country_code => "SRD",
          symbol: "$"
      },
      {
          :country => "South Sudanese Pound",
          :country_code => "SSP",
          symbol: "£"
      },
      {
          :country => "São Tomé and Príncipe Dobra",
          :country_code => "STD"
      },
      {
          :country => "Salvadoran Colón",
          :country_code => "SVC"
      },
      {
          :country => "Syrian Pound",
          :country_code => "SYP",
          symbol: "£"
      },
      {
          :country => "Swazi Lilangeni",
          :country_code => "SZL"
      },
      {
          :country => "Thai Baht",
          :country_code => "THB"
      },
      {
          :country => "Tajikistani Somoni",
          :country_code => "TJS"
      },
      {
          :country => "Turkmenistani Manat",
          :country_code => "TMT"
      },
      {
          :country => "Tunisian Dinar",
          :country_code => "TND"
      },
      {
          :country => "Tongan Pa'anga",
          :country_code => "TOP"
      },
      {
          :country => "Turkish Lira",
          :country_code => "TRY"
      },
      {
          :country => "Trinidad and Tobago Dollar",
          :country_code => "TTD",
          symbol: "TT$"
      },
      {
          :country => "New Taiwan Dollar",
          :country_code => "TWD",
          symbol: "NT$"
      },
      {
          :country => "Tanzanian Shilling",
          :country_code => "TZS"
      },
      {
          :country => "Ukrainian Hryvnia",
          :country_code => "UAH"
      },
      {
          :country => "Ugandan Shilling",
          :country_code => "UGX"
      },
      {
          :country => "Uruguayan Peso",
          :country_code => "UYU"
      },
      {
          :country => "Uzbekistan Som",
          :country_code => "UZS"
      },
      {
          :country => "Venezuelan Bolívar Fuerte",
          :country_code => "VEF",
          symbol: "Bs"
      },
      {
          :country => "Vietnamese Dong",
          :country_code => "VND",
          symbol: "₫"
      },
      {
          :country => "Vanuatu Vatu",
          :country_code => "VUV"
      },
      {
          :country => "Samoan Tala",
          :country_code => "WST"
      },
      {
          :country => "CFA Franc BEAC",
          :country_code => "XAF"
      },
      {
          :country => "Silver Ounce",
          :country_code => "XAG"
      },
      {
          :country => "Gold Ounce",
          :country_code => "XAU"
      },
      {
          :country => "East Caribbean Dollar",
          :country_code => "XCD",
          symbol: "$"
      },
      {
          :country => "Special Drawing Rights",
          :country_code => "XDR"
      },
      {
          :country => "CFA Franc BCEAO",
          :country_code => "XOF"
      },
      {
          :country => "Palladium Ounce",
          :country_code => "XPD"
      },
      {
          :country => "CFP Franc",
          :country_code => "XPF"
      },
      {
          :country => "Platinum Ounce",
          :country_code => "XPT"
      },
      {
          :country => "Yemeni Rial",
          :country_code => "YER",
          symbol: "﷼"
      },
      {
          :country => "South African Rand",
          :country_code => "ZAR",
          symbol: "R"
      },
      {
          :country => "Zambian Kwacha",
          :country_code => "ZMW"
      },
      {
          :country => "Zimbabwean Dollar",
          :country_code => "ZWL",
          symbol: "Z$"
      }
  ]

  def self.seed_data
    CURRENCIES.each do |currency, index|
      if Currency.find_by(country_code: currency[:country_code]).present?
        next
      else
        Currency.create(country: currency[:country], country_code: currency[:country_code], symbol: currency[:symbol])
      end
    end
  end
end
