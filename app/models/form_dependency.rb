# == Schema Information
#
# Table name: form_dependencies
#
#  id                    :bigint           not null
#  company_id            :integer          not null
#  controlling_entity_id :string(255)      not null
#  dependent_entity_id   :string(255)      not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  uuid                  :string(36)       primary key
#  form_id               :string(255)      not null
#

class FormDependency < ApplicationRecord
  include UUIDHelper

  belongs_to :form
  belongs_to :company
  belongs_to :controlling_entity, class_name: 'FormEntity'
  belongs_to :dependent_entity, class_name: 'FormEntity'
  has_many :dependency_mappings, class_name: "FormDependencyMapping"

  accepts_nested_attributes_for :dependency_mappings
end
