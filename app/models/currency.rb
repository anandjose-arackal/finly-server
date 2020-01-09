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


class Currency < ApplicationRecord

  has_many :amounts

  # since default currency is INR
  def self.default_currency_id
    1
  end

  def as_json(options = {})
    {
        id: self.id,
        country: self.country,
        country_code: self.country_code,
        symbol: self.symbol
    }
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
          :country => "United Arab Emirates Dirham",
          :country_code => "AED",
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
          :country_code => "AOA",
          symbol: ""
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
          :country_code => "BDT",
          symbol: ""
      },
      {
          :country => "Bulgarian Lev",
          :country_code => "BGN",
          symbol: "лв"
      },
      {
          :country => "Bahraini Dinar",
          :country_code => "BHD",
          symbol: ""
      },
      {
          :country => "Burundian Franc",
          :country_code => "BIF",
          symbol: ""
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
          :country_code => "BOB",
          symbol: "$b"
      },
      {
          :country => "Brazilian Real",
          :country_code => "BRL",
          symbol: "R$"
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
          :country_code => "BTN",
          symbol: ""
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
          :country_code => "CDF",
          symbol: ""
      },
      {
          :country => "Swiss Franc",
          :country_code => "CHF",
          symbol: "CHF"
      },
      {
          :country => "Chilean Unit of Account (UF)",
          :country_code => "CLF",
          symbol: ""
      },
      {
          :country => "Chilean Peso",
          :country_code => "CLP",
          symbol: "$"
      },
      {
          :country => "Chinese Yuan (Offshore)",
          :country_code => "CNH"
      },
      {
          :country => "Colombian Peso",
          :country_code => "COP",
          symbol: "$"
      },
      {
          :country => "Costa Rican Colón",
          :country_code => "CRC",
          symbol: "₡"
      },
      {
          :country => "Cuban Convertible Peso",
          :country_code => "CUC",
          symbol: ""
      },
      {
          :country => "Cuban Peso",
          :country_code => "CUP",
          symbol: "₱"
      },
      {
          :country => "Cape Verdean Escudo",
          :country_code => "CVE",
          symbol: ""
      },
      {
          :country => "Czech Republic Koruna",
          :country_code => "CZK",
          symbol: "Kč"
      },
      {
          :country => "Djiboutian Franc",
          :country_code => "DJF",
          symbol: ""
      },
      {
          :country => "Danish Krone",
          :country_code => "DKK",
          symbol: "kr"
      },
      {
          :country => "Dominican Peso",
          :country_code => "DOP",
          symbol: "RD$"
      },
      {
          :country => "Algerian Dinar",
          :country_code => "DZD",
          symbol: ""
      },
      {
          :country => "Egyptian Pound",
          :country_code => "EGP",
          symbol: "£"
      },
      {
          :country => "Eritrean Nakfa",
          :country_code => "ERN",
          symbol: ""
      },
      {
          :country => "Ethiopian Birr",
          :country_code => "ETB",
          symbol: ""
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
          :country_code => "GEL",
          symbol: "₾"
      },
      {
          :country => "Guernsey Pound",
          :country_code => "GGP",
          symbol: "£"
      },
      {
          :country => "Ghanaian Cedi",
          :country_code => "GHS",
          symbol: "¢"
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
          :country_code => "GTQ",
          symbol: "Q"
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
          :country_code => "HNL",
          symbol: "L"
      },
      {
          :country => "Croatian Kuna",
          :country_code => "HRK",
          symbol: "kn"
      },
      {
          :country => "Haitian Gourde",
          :country_code => "HTG",
          symbol: ""
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
          :country_code => "IRR",
          symbol: "﷼"
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
          :country_code => "KHR",
          symbol: "៛"
      },
      {
          :country => "Comorian Franc",
          :country_code => "KMF",
          symbol: ""
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
          :country_code => "LAK",
          symbol: "₭"
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
          :country_code => "LSL",
          symbol: ""
      },
      {
          :country => "Libyan Dinar",
          :country_code => "LYD",
          symbol: ""
      },
      {
          :country => "Moroccan Dirham",
          :country_code => "MAD",
          symbol: ""
      },
      {
          :country => "Moldovan Leu",
          :country_code => "MDL",
          symbol: ""
      },
      {
          :country => "Malagasy Ariary",
          :country_code => "MGA",
          symbol: ""
      },
      {
          :country => "Macedonian Denar",
          :country_code => "MKD",
          symbol: "ден"
      },
      {
          :country => "Myanma Kyat",
          :country_code => "MMK",
          symbol: ""
      },
      {
          :country => "Mongolian Tugrik",
          :country_code => "MNT",
          symbol: "₮"
      },
      {
          :country => "Macanese Pataca",
          :country_code => "MOP"
      },
      {
          :country => "Mauritanian Ouguiya",
          :country_code => "MRO",
          symbol: ""
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
          :country_code => "MXN",
          symbol: "$"
      },
      {
          :country => "Malaysian Ringgit",
          :country_code => "MYR",
          symbol: "RM"
      },
      {
          :country => "Mozambican Metical",
          :country_code => "MZN",
          symbol: "MT"
      },
      {
          :country => "Namibian Dollar",
          :country_code => "NAD",
          symbol: "$"
      },
      {
          :country => "Nigerian Naira",
          :country_code => "NGN",
          symbol: "₦"
      },
      {
          :country => "Nicaraguan Córdoba",
          :country_code => "NIO",
          symbol: "N$"
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
          :country_code => "OMR",
          symbol: "﷼"
      },
      {
          :country => "Panamanian Balboa",
          :country_code => "PAB",
          symbol: "B/."
      },
      {
          :country => "Peruvian Nuevo Sol",
          :country_code => "PEN",
          symbol: "S/."
      },
      {
          :country => "Papua New Guinean Kina",
          :country_code => "PGK",
          symbol: ""
      },
      {
          :country => "Philippine Peso",
          :country_code => "PHP",
          symbol: "₱"
      },
      {
          :country => "Pakistani Rupee",
          :country_code => "PKR",
          symbol: "Rs"
      },
      {
          :country => "Polish Zloty",
          :country_code => "PLN",
          symbol: "zł"
      },
      {
          :country => "Paraguayan Guarani",
          :country_code => "PYG",
          symbol: "Gs"
      },
      {
          :country => "Qatari Rial",
          :country_code => "QAR",
          symbol: "﷼"
      },
      {
          :country => "Romanian Leu",
          :country_code => "RON",
          symbol: "lei"
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
          :country_code => "SAR",
          symbol: "﷼"
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
          :country_code => "SLL",
          symbol: ""
      },
      {
          :country => "Somali Shilling",
          :country_code => "SOS",
          symbol: "S"
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
          :country_code => "THB",
          symbol: "฿"
      },
      {
          :country => "Tajikistani Somoni",
          :country_code => "TJS",
          symbol: ""
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
          :country_code => "TRY",
          symbol: ""
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

  def self.id_for(country_code)
    Currency.find_by(country_code: country_code)&.id
  end

  def self.currency_for(country_code)
    Currency.find_by(country_code: country_code)
  end

  def self.seed_data
    CURRENCIES.each do |currency, index|
      if Currency.find_by(country_code: currency[:country_code]).present?
        next
      else
        Currency.create(country: currency[:country], country_code: currency[:country_code], symbol: currency[:symbol])
      end
    end
  end

  def self.refresh_cache
    SEEDABLE_CACHE[name] = {}.with_indifferent_access
    as_hash&.each do |key, val|
      SEEDABLE_CACHE[name][key] = val
    end
  end

  # Generates a hash out of all the values in {name: id} format
  def self.as_hash
    values = HashInsensitive.new

    return values unless ApplicationRecord.connection.table_exists? self.table_name
    self.all.each do |item|
      values[item.country_code] = item.id
    end

    values.with_indifferent_access
  end

  refresh_cache

end
