# == Schema Information
#
# Table name: field_multiselect_selections
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FieldMultiselectSelection < ApplicationRecord
  has_one :custom_field, as: :value
  has_one :field_configuration, as: :default_value

  has_many :field_multiselect_selection_items

  accepts_nested_attributes_for :field_multiselect_selection_items
end
