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

  def as_json(options={})
    data = {}

  end

end
