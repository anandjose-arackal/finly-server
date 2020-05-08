class FormChoiceDependencyMapping < ApplicationRecord
  belongs_to :dependency, class_name: "FormChoiceDependency"
  belongs_to :form_rule
  # belongs_to :form_entity_choice
end
