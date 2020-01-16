# == Schema Information
#
# Table name: field_multiselect_selection_items
#
#  id                             :integer          not null, primary key
#  value_id                       :integer
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  field_multiselect_selection_id :integer
#

class FieldMultiselectSelectionItem < ApplicationRecord
  belongs_to :field_multiselect_selection, optional: true

  belongs_to :value, optional: true, class_name: 'FieldMultiselectItem'

  scope :with_value, -> (value_id) { where value_id: value_id}
  scope :with_id, -> (id) { where id: id}
  scope :with_field_multiselect_selection, -> (id) { where field_multiselect_selection_id: id}
end
