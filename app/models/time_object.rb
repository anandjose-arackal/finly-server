# == Schema Information
#
# Table name: time_objects
#
#  id               :integer          not null, primary key
#  value            :decimal(10, 4)
#  physical_unit_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class TimeObject < ApplicationRecord
  belongs_to :physical_unit, optional: true

  validate :non_zero_value
  validates :physical_unit, presence: true

  before_validation {
    self.physical_unit_id = PhysicalUnit.hour_id if self.physical_unit_id.nil?
  }

  def time_object_value
    self.value
  end

  private

  def non_zero_value
    if self.value.present?
      if self.value < 0 || self.value == 0
        errors.add(:time, "cannot be negative")
      end
    else
      errors.add(:time, "cannot be empty")
    end
  end

end
