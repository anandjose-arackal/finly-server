# == Schema Information
#
# Table name: gstins
#
#  id                       :bigint           not null, primary key
#  gstin                    :string(255)
#  legal_name_of_business   :string(255)
#  state                    :string(255)
#  date_of_registration     :date
#  constitution_of_business :string(255)
#  taxpayer_type            :string(255)
#  status                   :string(255)
#  api_response             :text(16777215)
#  api_provider             :string(255)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  address                  :text(65535)
#  trade_name               :string(255)
#

class Gstin < ApplicationRecord
  serialize :api_response, Hash
  scope :with_gstin, -> (gstin) {where gstin: gstin}

  def as_json
    {
      gstin: gstin,
      legal_name_of_business: legal_name_of_business,
      trade_name: trade_name,
      state: state,
      date_of_registration: date_of_registration,
      constitution_of_business: constitution_of_business,
      taxpayer_type: taxpayer_type,
      status: status,
      api_response: api_response,
      api_provider: api_provider,
      address: address
    }
  end
end


# {
#     "error": false,
#     "data": {
#         "stjCd": "KA011",
#         "lgnm": "VV Finly Technology Private Limited",
#         "stj": "LVO 040 - BENGALURU",
#         "dty": "Regular",
#         "adadr": [],
#         "cxdt": "",
#         "gstin": "29AAGCV7942K1ZL",
#         "nba": [
#             "Supplier of Services"
#         ],
#         "lstupdt": "05/03/2019",
#         "rgdt": "05/03/2019",
#         "ctb": "Private Limited Company",
#         "pradr": {
#             "addr": {
#                 "bnm": "Wilson Court Apts",
#                 "st": "6th cross, 12th Main, Wilson Garden",
#                 "loc": "Bangalore",
#                 "bno": "S-204",
#                 "stcd": "Karnataka",
#                 "dst": "Bengaluru (Bangalore) Urban",
#                 "city": "",
#                 "flno": "",
#                 "lt": "",
#                 "pncd": "560027",
#                 "lg": ""
#             },
#             "ntr": "Supplier of Services"
#         },
#         "tradeNam": "VV Finly Technology Private Limited",
#         "ctjCd": "YV0205",
#         "sts": "Active",
#         "ctj": "RANGE-ESD2"
#     }
# }
