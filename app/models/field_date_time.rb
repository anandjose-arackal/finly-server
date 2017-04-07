# == Schema Information
#
# Table name: field_date_times
#
#  id         :integer          not null, primary key
#  value      :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FieldDateTime < ActiveRecord::Base
  has_one :custom_field, as: :value
  has_one :field_configuration, as: :default_value

  validates :value, presence: true

  def value_as_datetime
    value.strftime("%I:%M %p, %d %b %Y")
  end
end
