# == Schema Information
#
# Table name: distances
#
#  id               :integer          not null, primary key
#  value            :decimal(10, 4)
#  physical_unit_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Distance < ApplicationRecord
  belongs_to :physical_unit, optional: true

  validates :value, presence: true
  validates :physical_unit_id, presence: true

  before_save {
    self.physical_unit_id = PhysicalUnit.kilometre_id if self.physical_unit_id.nil?
    if self.value.blank?
      self.value = 0
    end
  }

  before_validation {
    self.physical_unit_id = PhysicalUnit.kilometre_id if self.physical_unit_id.nil?
    if self.value.blank?
      self.value = 0
    end
  }

  def distance_value
    self.value
  end

  alias_method :maps_distance_value, :distance_value

end
