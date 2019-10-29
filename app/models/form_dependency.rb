class FormDependency < ApplicationRecord
  belongs_to :company
  belongs_to :dependency_type, class_name: 'FormDependencyType'
  belongs_to :controlling_user, class_name: 'User'
  belongs_to :controlling_entity, class_name: 'FormEntity'
  belongs_to :dependent_entity, class_name: 'FormEntity'
  has_many :choice_dependencies, class_name: "FormDependencyChoice"
end
