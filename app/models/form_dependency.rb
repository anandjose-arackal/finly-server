# == Schema Information
#
# Table name: form_dependencies
#
#  id                    :bigint           not null, primary key
#  company_id            :integer          not null
#  dependency_type_id    :integer          not null
#  controlling_user_id   :integer          not null
#  controlling_entity_id :integer          not null
#  dependent_entity_id   :integer          not null
#  created_by_id         :integer          not null
#  updated_by_id         :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class FormDependency < ApplicationRecord
  belongs_to :company
  belongs_to :dependency_type, class_name: 'FormDependencyType'
  belongs_to :controlling_user, class_name: 'User'
  belongs_to :controlling_entity, class_name: 'FormEntity'
  belongs_to :dependent_entity, class_name: 'FormEntity'
  has_many :choice_dependencies, class_name: "FormDependencyChoice"
end
