# == Schema Information
#
# Table name: form_choice_dependency_mappings
#
#  id                    :bigint           not null, primary key
#  dependency_id         :string(36)       not null
#  form_rule_id          :string(36)       not null
#  form_entity_choice_id :string(36)       not null
#  deleted_at            :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class FormChoiceDependencyMapping < ApplicationRecord
  belongs_to :dependency, class_name: "FormChoiceDependency"
  belongs_to :form_rule
  # belongs_to :form_entity_choice

  amoeba do
    include_associations [:form_rule]
  end
end
