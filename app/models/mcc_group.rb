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
    CODE_MAP[id][:code]
  end

end
