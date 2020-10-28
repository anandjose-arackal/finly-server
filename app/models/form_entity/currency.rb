# == Schema Information
#
# Table name: form_entities
#
#  id                           :bigint           not null
#  uuid                         :string(36)       not null, primary key
#  company_id                   :integer          not null
#  form_id                      :string(36)       not null
#  form_section_id              :string(36)       not null
#  created_by_user_id           :integer
#  entity_key                   :string(255)      not null
#  label                        :string(255)
#  placeholder                  :string(255)
#  hint                         :string(255)
#  entity_type                  :string(255)
#  default_value                :string(255)
#  editable                     :boolean
#  required                     :boolean
#  active                       :boolean
#  unique                       :boolean
#  visible                      :boolean
#  position                     :integer
#  system_field                 :boolean
#  can_visible_be_changed       :boolean
#  can_editable_be_changed      :boolean
#  can_required_be_changed      :boolean
#  can_uniqueness_be_changed    :boolean
#  can_be_disabled              :boolean
#  can_label_be_renamed         :boolean
#  can_choices_be_changed       :boolean
#  allow_clearing_default_value :boolean
#  options                      :text(65535)
#  data_provider                :text(65535)
#  deleted_at                   :datetime
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  choices_scope                :text(65535)
#  internal                     :boolean          default(FALSE)
#  is_modified                  :boolean          default(FALSE)
#  entity_path                  :string(255)
#  parent_id                    :string(255)
#  populate_if_empty            :string(255)
#  type                         :string(255)
#  config                       :text(65535)
#  associate_custom_fields      :boolean
#  compute_enabled              :boolean
#  compute_type_id              :integer
#  compute_lookup_entity_id     :string(255)
#  compute_formula              :text(65535)
#  filters                      :text(65535)
#  config_path                  :string(255)
#

class FormEntity::Currency < FormEntity
  register :currency
  set :hint, 'Select value'

  CURRENCIES ||= [ { currency: "India Rupee", currency_code: "INR", symbol: "₹" }, { currency: "United States of America Dollar", currency_code: "USD", symbol: "$" }, { currency: "United Kingdom Pound", currency_code: "GBP", symbol: "£" }, { currency: "Australia Dollar", currency_code: "AUD", symbol: "$" }, { currency: "Europe Euro", currency_code: "EUR", symbol: "€" }, { currency: "China Yuan", currency_code: "CNY", symbol: "¥" }, { currency: "Japan Yen", currency_code: "JPY", symbol: "¥" }, { currency: "New Zealand Dollar", currency_code: "NZD", symbol: "$" }, { currency: "Russia Ruble", currency_code: "RUB", symbol: "₽" }, { :currency => "United Arab Emirates Dirham", :currency_code => "AED", symbol: "" }, { :currency => "Afghan Afghani", :currency_code => "AFN", symbol: "؋" }, { :currency => "Albanian Lek", :currency_code => "ALL", symbol: "Lek" }, { :currency => "Armenian Dram", :currency_code => "AMD", symbol: "դր." }, { :currency => "Netherlands Antillean Guilder", :currency_code => "ANG", symbol: "ƒ" }, { :currency => "Angolan Kwanza", :currency_code => "AOA", symbol: "" }, { :currency => "Argentine Peso", :currency_code => "ARS", symbol: "$" }, { :currency => "Aruban Florin", :currency_code => "AWG", symbol: "" }, { :currency => "Azerbaijani Manat", :currency_code => "AZN", symbol: "₼" }, { :currency => "Bosnia-Herzegovina Convertible Mark", :currency_code => "BAM", symbol: "KM" }, { :currency => "Barbadian Dollar", :currency_code => "BBD", symbol: "$" }, { :currency => "Bangladeshi Taka", :currency_code => "BDT", symbol: "" }, { :currency => "Bulgarian Lev", :currency_code => "BGN", symbol: "лв" }, { :currency => "Bahraini Dinar", :currency_code => "BHD", symbol: "" }, { :currency => "Burundian Franc", :currency_code => "BIF", symbol: "" }, { :currency => "Bermudan Dollar", :currency_code => "BMD", symbol: "$" }, { :currency => "Brunei Dollar", :currency_code => "BND", symbol: "$" }, { :currency => "Bolivian Boliviano", :currency_code => "BOB", symbol: "$b" }, { :currency => "Brazilian Real", :currency_code => "BRL", symbol: "R$" }, { :currency => "Bahamian Dollar", :currency_code => "BSD", symbol: "$" }, { :currency => "Bitcoin", :currency_code => "BTC" }, { :currency => "Bhutanese Ngultrum", :currency_code => "BTN", symbol: "" }, { :currency => "Botswanan Pula", :currency_code => "BWP" }, { :currency => "Belarusian Ruble", :currency_code => "BYN" }, { :currency => "Belize Dollar", :currency_code => "BZD", symbol: "$" }, { :currency => "Canadian Dollar", :currency_code => "CAD", symbol: "$" }, { :currency => "Congolese Franc", :currency_code => "CDF", symbol: "" }, { :currency => "Swiss Franc", :currency_code => "CHF", symbol: "CHF" }, { :currency => "Chilean Unit of Account (UF)", :currency_code => "CLF", symbol: "" }, { :currency => "Chilean Peso", :currency_code => "CLP", symbol: "$" }, { :currency => "Chinese Yuan (Offshore)", :currency_code => "CNH" }, { :currency => "Colombian Peso", :currency_code => "COP", symbol: "$" }, { :currency => "Costa Rican Colón", :currency_code => "CRC", symbol: "₡" }, { :currency => "Cuban Convertible Peso", :currency_code => "CUC", symbol: "" }, { :currency => "Cuban Peso", :currency_code => "CUP", symbol: "₱" }, { :currency => "Cape Verdean Escudo", :currency_code => "CVE", symbol: "" }, { :currency => "Czech Republic Koruna", :currency_code => "CZK", symbol: "Kč" }, { :currency => "Djiboutian Franc", :currency_code => "DJF", symbol: "" }, { :currency => "Danish Krone", :currency_code => "DKK", symbol: "kr" }, { :currency => "Dominican Peso", :currency_code => "DOP", symbol: "RD$" }, { :currency => "Algerian Dinar", :currency_code => "DZD", symbol: "" }, { :currency => "Egyptian Pound", :currency_code => "EGP", symbol: "£" }, { :currency => "Eritrean Nakfa", :currency_code => "ERN", symbol: "" }, { :currency => "Ethiopian Birr", :currency_code => "ETB", symbol: "" }, { :currency => "Fijian Dollar", :currency_code => "FJD", symbol: "$" }, { :currency => "Falkland Islands Pound", :currency_code => "FKP", symbol: "£" }, { :currency => "Georgian Lari", :currency_code => "GEL", symbol: "₾" }, { :currency => "Guernsey Pound", :currency_code => "GGP", symbol: "£" }, { :currency => "Ghanaian Cedi", :currency_code => "GHS", symbol: "¢" }, { :currency => "Gibraltar Pound", :currency_code => "GIP", symbol: "£" }, { :currency => "Gambian Dalasi", :currency_code => "GMD" }, { :currency => "Guinean Franc", :currency_code => "GNF" }, { :currency => "Guatemalan Quetzal", :currency_code => "GTQ", symbol: "Q" }, { :currency => "Guyanaese Dollar", :currency_code => "GYD", symbol: "$" }, { :currency => "Hong Kong Dollar", :currency_code => "HKD", symbol: "$" }, { :currency => "Honduran Lempira", :currency_code => "HNL", symbol: "L" }, { :currency => "Croatian Kuna", :currency_code => "HRK", symbol: "kn" }, { :currency => "Haitian Gourde", :currency_code => "HTG", symbol: "" }, { :currency => "Hungarian Forint", :currency_code => "HUF", symbol: "Ft" }, { :currency => "Indonesian Rupiah", :currency_code => "IDR", symbol: "Rp" }, { :currency => "Israeli New Sheqel", :currency_code => "ILS", symbol: "₪" }, { :currency => "Manx pound", :currency_code => "IMP", symbol: "£" }, { :currency => "Iraqi Dinar", :currency_code => "IQD" }, { :currency => "Iranian Rial", :currency_code => "IRR", symbol: "﷼" }, { :currency => "Icelandic Króna", :currency_code => "ISK", symbol: "kr" }, { :currency => "Jersey Pound", :currency_code => "JEP", symbol: "£" }, { :currency => "Jamaican Dollar", :currency_code => "JMD", symbol: "J$" }, { :currency => "Jordanian Dinar", :currency_code => "JOD" }, { :currency => "Kenyan Shilling", :currency_code => "KES" }, { :currency => "Kyrgystani Som", :currency_code => "KGS", symbol: "лв" }, { :currency => "Cambodian Riel", :currency_code => "KHR", symbol: "៛" }, { :currency => "Comorian Franc", :currency_code => "KMF", symbol: "" }, { :currency => "North Korean Won", :currency_code => "KPW", symbol: "₩" }, { :currency => "South Korean Won", :currency_code => "KRW", symbol: "₩" }, { :currency => "Kuwaiti Dinar", :currency_code => "KWD" }, { :currency => "Cayman Islands Dollar", :currency_code => "KYD", symbol: "$" }, { :currency => "Kazakhstani Tenge", :currency_code => "KZT", symbol: "лв" }, { :currency => "Laotian Kip", :currency_code => "LAK", symbol: "₭" }, { :currency => "Lebanese Pound", :currency_code => "LBP", symbol: "£" }, { :currency => "Sri Lankan Rupee", :currency_code => "LKR", symbol: "Rs" }, { :currency => "Liberian Dollar", :currency_code => "LRD", symbol: "$" }, { :currency => "Lesotho Loti", :currency_code => "LSL", symbol: "" }, { :currency => "Libyan Dinar", :currency_code => "LYD", symbol: "" }, { :currency => "Moroccan Dirham", :currency_code => "MAD", symbol: "" }, { :currency => "Moldovan Leu", :currency_code => "MDL", symbol: "" }, { :currency => "Malagasy Ariary", :currency_code => "MGA", symbol: "" }, { :currency => "Macedonian Denar", :currency_code => "MKD", symbol: "ден" }, { :currency => "Myanma Kyat", :currency_code => "MMK", symbol: "" }, { :currency => "Mongolian Tugrik", :currency_code => "MNT", symbol: "₮" }, { :currency => "Macanese Pataca", :currency_code => "MOP" }, { :currency => "Mauritanian Ouguiya", :currency_code => "MRO", symbol: "" }, { :currency => "Mauritian Rupee", :currency_code => "MUR", symbol: "Rs" }, { :currency => "Maldivian Rufiyaa", :currency_code => "MVR" }, { :currency => "Malawian Kwacha", :currency_code => "MWK" }, { :currency => "Mexican Peso", :currency_code => "MXN", symbol: "$" }, { :currency => "Malaysian Ringgit", :currency_code => "MYR", symbol: "RM" }, { :currency => "Mozambican Metical", :currency_code => "MZN", symbol: "MT" }, { :currency => "Namibian Dollar", :currency_code => "NAD", symbol: "$" }, { :currency => "Nigerian Naira", :currency_code => "NGN", symbol: "₦" }, { :currency => "Nicaraguan Córdoba", :currency_code => "NIO", symbol: "N$" }, { :currency => "Norwegian Krone", :currency_code => "NOK", symbol: "kr" }, { :currency => "Nepalese Rupee", :currency_code => "NPR", symbol: "Rs" }, { :currency => "Omani Rial", :currency_code => "OMR", symbol: "﷼" }, { :currency => "Panamanian Balboa", :currency_code => "PAB", symbol: "B/." }, { :currency => "Peruvian Nuevo Sol", :currency_code => "PEN", symbol: "S/." }, { :currency => "Papua New Guinean Kina", :currency_code => "PGK", symbol: "" }, { :currency => "Philippine Peso", :currency_code => "PHP", symbol: "₱" }, { :currency => "Pakistani Rupee", :currency_code => "PKR", symbol: "Rs" }, { :currency => "Polish Zloty", :currency_code => "PLN", symbol: "zł" }, { :currency => "Paraguayan Guarani", :currency_code => "PYG", symbol: "Gs" }, { :currency => "Qatari Rial", :currency_code => "QAR", symbol: "﷼" }, { :currency => "Romanian Leu", :currency_code => "RON", symbol: "lei" }, { :currency => "Serbian Dinar", :currency_code => "RSD", symbol: "Дин." }, { :currency => "Rwandan Franc", :currency_code => "RWF" }, { :currency => "Saudi Riyal", :currency_code => "SAR", symbol: "﷼" }, { :currency => "Solomon Islands Dollar", :currency_code => "SBD", symbol: "$" }, { :currency => "Seychellois Rupee", :currency_code => "SCR", symbol: "Rs" }, { :currency => "Sudanese Pound", :currency_code => "SDG", symbol: "£" }, { :currency => "Swedish Krona", :currency_code => "SEK", symbol: "kr" }, { :currency => "Singapore Dollar", :currency_code => "SGD", symbol: "$" }, { :currency => "Saint Helena Pound", :currency_code => "SHP", symbol: "£" }, { :currency => "Sierra Leonean Leone", :currency_code => "SLL", symbol: "" }, { :currency => "Somali Shilling", :currency_code => "SOS", symbol: "S" }, { :currency => "Surinamese Dollar", :currency_code => "SRD", symbol: "$" }, { :currency => "South Sudanese Pound", :currency_code => "SSP", symbol: "£" }, { :currency => "São Tomé and Príncipe Dobra", :currency_code => "STD" }, { :currency => "Salvadoran Colón", :currency_code => "SVC" }, { :currency => "Syrian Pound", :currency_code => "SYP", symbol: "£" }, { :currency => "Swazi Lilangeni", :currency_code => "SZL" }, { :currency => "Thai Baht", :currency_code => "THB", symbol: "฿" }, { :currency => "Tajikistani Somoni", :currency_code => "TJS", symbol: "" }, { :currency => "Turkmenistani Manat", :currency_code => "TMT" }, { :currency => "Tunisian Dinar", :currency_code => "TND" }, { :currency => "Tongan Pa'anga", :currency_code => "TOP" }, { :currency => "Turkish Lira", :currency_code => "TRY", symbol: "" }, { :currency => "Trinidad and Tobago Dollar", :currency_code => "TTD", symbol: "TT$" }, { :currency => "New Taiwan Dollar", :currency_code => "TWD", symbol: "NT$" }, { :currency => "Tanzanian Shilling", :currency_code => "TZS" }, { :currency => "Ukrainian Hryvnia", :currency_code => "UAH" }, { :currency => "Ugandan Shilling", :currency_code => "UGX" }, { :currency => "Uruguayan Peso", :currency_code => "UYU" }, { :currency => "Uzbekistan Som", :currency_code => "UZS" }, { :currency => "Venezuelan Bolívar Fuerte", :currency_code => "VEF", symbol: "Bs" }, { :currency => "Vietnamese Dong", :currency_code => "VND", symbol: "₫" }, { :currency => "Vanuatu Vatu", :currency_code => "VUV" }, { :currency => "Samoan Tala", :currency_code => "WST" }, { :currency => "CFA Franc BEAC", :currency_code => "XAF" }, { :currency => "Silver Ounce", :currency_code => "XAG" }, { :currency => "Gold Ounce", :currency_code => "XAU" }, { :currency => "East Caribbean Dollar", :currency_code => "XCD", symbol: "$" }, { :currency => "Special Drawing Rights", :currency_code => "XDR" }, { :currency => "CFA Franc BCEAO", :currency_code => "XOF" }, { :currency => "Palladium Ounce", :currency_code => "XPD" }, { :currency => "CFP Franc", :currency_code => "XPF" }, { :currency => "Platinum Ounce", :currency_code => "XPT" }, { :currency => "Yemeni Rial", :currency_code => "YER", symbol: "﷼" }, { :currency => "South African Rand", :currency_code => "ZAR", symbol: "R" }, { :currency => "Zambian Kwacha", :currency_code => "ZMW" }, { :currency => "Zimbabwean Dollar", :currency_code => "ZWL", symbol: "Z$" } ]

  operators :eq_any, :not_eq_all, :not_null, :null

  option :currencies, default: CURRENCIES

  schema_validation do
    required(:options) do
      hash do
        required(:currencies).array do
          hash do
            required(:currency).filled(included_in?: CURRENCIES.map {|item| item[:currency]})
            required(:currency_code).filled(included_in?: CURRENCIES.map {|item| item[:currency_code]})
            optional(:symbol).value(included_in?: CURRENCIES.map {|item| item[:symbol]})
          end
        end
      end
    end
  end

  def self.option_validation
    Proc.new do
      validation :options_config do
        params do
          required(:options) do
            hash do
              required(:currencies).array do
                hash do
                  required(:currency)
                  # required(:currency_code).filled(included_in?: CURRENCIES.map {|item| item[:currency_code]})
                  # optional(:symbol).value(included_in?: CURRENCIES.map {|item| item[:symbol]})
                end
              end
            end
          end
        end

          # rule(:options) do
          #   if FormEntity::Currency::CURRENCIES.map {|item| item[:currency_code]}.exclude?(value[:currency])
          #     key.failure('invalid currency provided')
          #   end
          # end
      end
    end
  end
end
