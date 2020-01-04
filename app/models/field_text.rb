# == Schema Information
#
# Table name: field_texts
#
#  id         :integer          not null, primary key
#  value      :text(65535)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FieldText < ApplicationRecord
  has_one :custom_field, as: :value
  has_one :field_configuration, as: :default_value

  validates :value, presence: true

  after_save :update_value_in_custom_field
  

  def as_json(options={})
    {value: self.value}
  end

  def update_value_in_custom_field
    self&.custom_field&.update_column('configured_field_value', self&.value)
  end
end
