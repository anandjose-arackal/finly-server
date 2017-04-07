# == Schema Information
#
# Table name: field_booleans
#
#  id         :integer          not null, primary key
#  value      :boolean          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FieldBoolean < ActiveRecord::Base
  has_one :custom_field, as: :value
  has_one :field_configuration, as: :default_value

  validates :value, presence: true
end
