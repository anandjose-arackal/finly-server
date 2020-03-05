# == Schema Information
#
# Table name: form_dependency_choice_mappings
#
#  id                         :bigint           not null
#  company_id                 :integer          not null
#  form_dependency_mapping_id :string(255)      not null
#  dependent_choice_id        :string(255)      not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  uuid                       :string(36)       primary key
#  form_id                    :string(255)      not null
#  dependent_choice_type      :string(255)
#  deleted_at                 :datetime
#

class FormDependencyChoiceMapping < ApplicationRecord
  include UUIDHelper

  belongs_to :company
  belongs_to :form_dependency_mapping
  belongs_to :controlling_entity, class_name: "FormEntity"
  belongs_to :controlling_choice, polymorphic: true
  belongs_to :dependent_choice, polymorphic: true
end
