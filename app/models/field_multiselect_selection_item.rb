# == Schema Information
#
# Table name: field_multiselect_selection_items
#
#  id                             :integer          not null, primary key
#  value                          :integer
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  field_multiselect_selection_id :integer
#

class FieldMultiselectSelectionItem < ActiveRecord::Base
  belongs_to :field_multiselect_selection

  belongs_to :value, class_name: 'FieldMultiselectItem'
end
