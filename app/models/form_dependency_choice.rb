class FormDependencyChoice < ApplicationRecord
  belongs_to :company
  belongs_to :form_dependency
  belongs_to :controlling_choice, class_name: 'FormEntityChoice'
  has_many :dependency_choice_mappings, class_name: "FormDependencyChoiceMapping"
  has_many :dependent_choices, through: :dependency_choice_mappings, class_name: "FormEntityChoice", foreign_key: :dependent_choice_id
end
