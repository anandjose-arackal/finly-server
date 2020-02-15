# == Schema Information
#
# Table name: gst_state_codes
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  state_code :string(255)
#  uuid       :string(36)
#  deleted_at :datetime
#

class GstStateCode < ApplicationRecord
  include LiquidDroppable
include Exposures::Model::Exposable

  scope :with_state_code, -> (state_code) {
    where(state_code: state_code)
  }
  def full_name
    "#{self.name} - #{self.state_code}"
  end

  def as_json(options = {})
    {
        id: id,
        name: name,
        state_code: state_code
    }
  end

end
