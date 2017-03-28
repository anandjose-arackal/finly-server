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

  validates :value, presence: true
  validates :physical_unit_id, presence: true

  before_save {
    self.physical_unit_id = PhysicalUnit.kilometre_id if self.physical_unit_id.nil?
  }

  before_validation {
    self.physical_unit_id = PhysicalUnit.kilometre_id if self.physical_unit_id.nil?
  }

  def distance_value
    self.value
  end

end
