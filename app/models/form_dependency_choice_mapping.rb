class FormDependencyChoiceMapping < ApplicationRecord
  belongs_to :company
  belongs_to :form_dependency_choice
  belongs_to :dependent_choice, class_name: 'FormEntityChoice'
end
