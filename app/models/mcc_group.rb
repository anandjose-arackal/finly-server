# == Schema Information
#
# Table name: mcc_groups
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  code       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class MccGroup < ActiveRecord::Base

  CODE_MAP = {
      1 => {code: "ALCOHOL", name: "Liquor/Bar/Clubs"},
      2 => {code: "ELECTRONICS", name: "Electronics"},
      3 => {code: "ENTERTAINMENT", name: "Entertainment"},
      4 => {code: "FUEL", name: "Fuel"},
      5 => {code: "GROCERY", name: "Groceries"},
      6 => {code: "HARDWARE", name: "Hardware and Construction"},
      7 => {code: "HEALTHCARE", name: "Healthcare"},
      8 => {code: "HOTEL", name: "Hotel/Restaurant/Lodging"},
      9 => {code: "LOGISTICS", name: "Logistics"},
      10 => {code: "MEAL", name: "Food/Meals"},
      11 => {code: "METRO", name: "Metro"},
      12 => {code: "MOBILERECHARGE", name: "Mobile Recharge"},
      13 => {code: "PHARMACY", name: "Pharmacies"},
      14 => {code: "RETAIL", name: "Retail"},
      15 => {code: "TRANSPORT", name: "Train/Metro/Public Transit/Taxi/Airlines/Bus/Waterways/Car Rental"},
      16 => {code: "TRAVEL", name: "Hotel/Lodging/Food/Transportation/Fuel/Medical/Mail/Public Transit"},
      17 => {code: "UTILITY", name: "Utility Bills"},
      18 => {code: "GROUNDTRANSPORT", name: "Courier"},
  }

  def self.name_for(id)
    CODE_MAP[id][:name] rescue nil
  end

  def self.code_for(id)
    if id.is_a?(String)
      id = id.to_i
    end
    code = CODE_MAP[id][:code] rescue nil
    if code
      return code
    else
      return "NA"
    end
  end

  def mcc_group_name
    self.name
  end

end
