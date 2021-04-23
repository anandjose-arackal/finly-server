# == Schema Information
#
# Table name: field_multiselect_selections
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class FieldMultiselectSelection < ApplicationRecord
  belongs_to :company, optional: true
  has_one :custom_field, as: :value
  has_one :field_configuration, as: :default_value

  has_many :field_multiselect_selection_items

  accepts_nested_attributes_for :field_multiselect_selection_items

  after_save :update_value_in_custom_field

  def update_value_in_custom_field
    joined_values = self.field_multiselect_selection_items.map {|items| items&.value&.name
    }&.join(',')
    self&.custom_field&.update_column('configured_field_value', joined_values)
  end
end
