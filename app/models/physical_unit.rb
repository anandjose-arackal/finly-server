# == Schema Information
#
# Table name: physical_units
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  symbol     :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PhysicalUnit < ActiveRecord::Base

  VALUES = {1 => {name: "Kilometre", symbol: "km"},
            2 => {name: "Mile", symbol: "mi"},
            3 => {name: "Hour", symbol: "hr"},
            4 => {name: "Minute", symbol: "min"},
            5 => {name: "Second", symbol: "s"}}
end
