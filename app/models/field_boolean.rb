# == Schema Information
#
# Table name: field_booleans
#
#  id         :integer          not null, primary key
#  value      :boolean          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FieldBoolean < ApplicationRecord
  has_one :custom_field, as: :value
  has_one :field_configuration, as: :default_value

  # cannot apply this validation as false is considered 'not present'
  # validates :value, presence: true
  validates :value, :inclusion => {:in => [false, true]}
end
