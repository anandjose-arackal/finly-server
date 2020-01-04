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

class PhysicalUnit < ApplicationRecord

  VALUES = {1 => {name: "Kilometre", symbol: "km"},
            2 => {name: "Mile", symbol: "mi"},
            3 => {name: "Hour", symbol: "hr"},
            4 => {name: "Minute", symbol: "min"},
            5 => {name: "Second", symbol: "s"}}

  def self.kilometre_id
    1
  end

  def self.mile_id
    2
  end

  def self.hour_id
    3
  end

  def self.minute_id
    4
  end

  def self.second_id
    5
  end

  def as_json(options={})
    {
        id: id,
        name: name
    }
  end


end
