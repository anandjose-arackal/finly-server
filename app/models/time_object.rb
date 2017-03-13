# == Schema Information
#
# Table name: time_objects
#
#  id               :integer          not null, primary key
#  value            :decimal(10, )
#  physical_unit_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class TimeObject < ActiveRecord::Base
  belongs_to :physical_unit

end
