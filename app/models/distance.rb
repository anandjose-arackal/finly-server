# == Schema Information
#
# Table name: distances
#
#  id               :integer          not null, primary key
#  value            :decimal(10, )
#  physical_unit_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Distance < ActiveRecord::Base
  belongs_to :physical_unit
end
