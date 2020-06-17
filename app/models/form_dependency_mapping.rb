# == Schema Information
#
# Table name: form_dependency_mappings
#
#  id                          :bigint           not null
#  company_id                  :integer          not null
#  form_dependency_id          :string(255)      not null
#  controlling_choice_id       :string(255)      not null
#  dependent_required          :boolean
#  dependent_visible           :boolean
#  dependent_editable          :boolean
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  deleted_at                  :datetime
#  form_id                     :string(255)      not null
#  controlling_choice_type     :string(255)
#  has_dependent_choices       :boolean
#  lazy_load_dependent_choices :boolean
#  controlling_entity_id       :integer
#  controlling_entity_key      :string(255)
#  dependent_entity_id         :integer
#  dependent_entity_key        :string(255)
#

class FormDependencyMapping < ApplicationRecord
  include UUIDHelper

  belongs_to :company
  belongs_to :form_dependency
  belongs_to :controlling_entity, class_name: "FormEntity"
  belongs_to :dependent_entity, class_name: "FormEntity"
  belongs_to :controlling_choice, polymorphic: true
  has_many :dependency_choice_mappings, class_name: "FormDependencyChoiceMapping"

  accepts_nested_attributes_for :dependency_choice_mappings
end
