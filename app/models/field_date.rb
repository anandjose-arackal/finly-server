# == Schema Information
#
# Table name: field_dates
#
#  id         :integer          not null, primary key
#  value      :date             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FieldDate < ApplicationRecord
  has_one :custom_field, as: :value
  has_one :field_configuration, as: :default_value

  validates :value, presence: true

  def value_as_date
    value.strftime("%d %b %Y")
  end

end
