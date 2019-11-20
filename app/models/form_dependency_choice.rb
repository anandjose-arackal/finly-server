# == Schema Information
#
# Table name: form_dependency_choices
#
#  id                        :bigint           not null, primary key
#  company_id                :integer          not null
#  form_dependency_id        :integer          not null
#  controlling_choice_id     :integer          not null
#  is_choice_selected        :boolean
#  dependent_entity_required :boolean
#  dependent_entity_visible  :boolean
#  dependent_entity_editable :boolean
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class FormDependencyChoice < ApplicationRecord
  belongs_to :company
  belongs_to :form_dependency
  belongs_to :controlling_choice, class_name: 'FormEntityChoice'
  has_many :dependency_choice_mappings, class_name: "FormDependencyChoiceMapping"
  has_many :dependent_choices, through: :dependency_choice_mappings, class_name: "FormEntityChoice", foreign_key: :dependent_choice_id
end
