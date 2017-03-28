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

  validates :value, presence: true
  validates :physical_unit, presence: true

  before_validation {
    self.physical_unit_id = PhysicalUnit.hour_id if self.physical_unit_id.nil?
  }

  def time_object_value
    self.value
  end

end
