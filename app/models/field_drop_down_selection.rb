# == Schema Information
#
# Table name: field_drop_down_selections
#
#  id         :integer          not null, primary key
#  value_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FieldDropDownSelection < ActiveRecord::Base
  has_one :custom_field, as: :value
  has_one :field_configuration, as: :default_value

  validates :value_id, presence: true
end
