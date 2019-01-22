# == Schema Information
#
# Table name: tds_rates_lists
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  tds        :decimal(10, 5)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :integer
#

class TdsRatesList < ApplicationRecord

  def self.seed_data(company_id)
    DEFAULTS.each do |rate|
      if TdsRatesList.find_by(name: rate[:name], company_id: company_id).present?
        next
      else
        TdsRatesList.create(name: rate[:name], tds: rate[:tds], company_id: company_id)
      end
    end
  end

  # For Olx
  # DEFAULTS = [
  #     {
  #         name: "TDS On Contractor - Individual",
  #         tds: "1"
  #     },
  #     {
  #         name: "TDS On Contractor - Company",
  #         tds: "2"
  #     },
  #     {
  #         name: "TDS On Professional Fees - Company",
  #         tds: "10"
  #     },
  #     {
  #         name: "TDS On Rent -Company",
  #         tds: "10"
  #     },
  #     {
  #         name: "TDS On Rent - Individual",
  #         tds: "10"
  #     },
  #     {
  #         name: "TDS On Professional Fees - Individual",
  #         tds: "10"
  #     },
  #     {
  #         name: "TDS On Commission",
  #         tds: "5"
  #     }
  # ]

  DEFAULTS = [
      {
          name: "Interest on securities",
          tds: 10
      },
      {
          name: "Dividend",
          tds: 10
      },
      {
          name: "Income by interest other than 'Interest on Securities'",
          tds: 10
      },
      {
          name: "Income through games of any sort",
          tds: 10
      },
      {
          name: "Income thorugh horse races",
          tds: 10
      },
      {
          name: "Payment to Contractors/Subcontractors - HUF/Individuals",
          tds: 1
      },
      {
          name: "Payment to Contractors/Subcontractors - Others",
          tds: 2
      },
      {
          name: "Insurance comission",
          tds: 10
      },
      {
          name: "Payment in respect of life insurance policy",
          tds: 1
      },
      {
          name: "Payment in respect of deposit under National Savings scheme",
          tds: 10
      },
      {
          name: "Payment on account of repurchase of unit by Mutual Fund or Unit Trust of India",
          tds: 20
      },
      {
          name: "Commission, etc., on sale of lottery tickets",
          tds: 10
      },
      {
          name: "Comission and brokerage",
          tds: 5
      },
      {
          name: "Rent on Plant and Machinery",
          tds: 2
      },
      {
          name: "Rent on Land or building or furniture or fitting",
          tds: 10
      },
      {
          name: "Payment on transfer of certain immovable property other than agricultural land",
          tds: 10
      },
      {
          name: "Fee for professional services",
          tds: 10
      },
      {
          name: "Fee for technical services",
          tds: 10
      },
      {
          name: "Royalty",
          tds: 10
      },
      {
          name: "Remuneration/fee/commission to a director",
          tds: 10
      },
      {
          name: "Payment of Compensation on acquisition of certain immovable property",
          tds: 10
      },
      {
          name: "Certain income distributed by a business trust to its unit holder",
          tds: 10
      },
      {
          name: "Any other income",
          tds: 10
      },

  ]
end
