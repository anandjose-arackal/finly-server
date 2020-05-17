# == Schema Information
#
# Table name: form_choice_dependency_mappings
#
#  id                    :bigint           not null, primary key
#  dependency_id         :string(36)       not null
#  dependent_choice_id   :string(36)       not null
#  deleted_at            :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  controlling_choice_id :string(255)
#

class FormChoiceDependencyMapping < ApplicationRecord
  belongs_to :dependency, class_name: "FormChoiceDependency"
end
