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

  VALUES = {}
end
