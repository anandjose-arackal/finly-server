# == Schema Information
#
# Table name: form_choice_dependencies
#
#  id                    :bigint           not null
#  uuid                  :string(36)       not null, primary key
#  company_id            :bigint           not null
#  form_id               :string(36)       not null
#  form_entity_id        :string(36)       not null
#  controlling_entity_id :string(36)       not null
#  dependency_id         :string(255)
#  custom                :boolean
#  is_updated            :boolean
#  can_be_updated        :boolean
#  created_by_id         :integer
#  updated_by_id         :integer
#  deleted_at            :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class FormChoiceDependency < ApplicationRecord
  include UUIDHelper

  belongs_to :company
  belongs_to :form
  belongs_to :form_entity
  belongs_to :controlling_entity, class_name: "FormEntity"
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :updated_by, class_name: 'User', optional: true

  has_many :rules, class_name: 'FormRule', as: :rule_parent
  has_many :mappings, class_name: 'FormChoiceDependencyMapping', foreign_key: :dependency_id

  # amoeba do
  #
  # end

  def as_json(options={})
    data = {}

  end

end
