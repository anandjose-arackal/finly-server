# == Schema Information
#
# Table name: forms
#
#  id         :bigint           not null
#  uuid       :string(36)       not null, primary key
#  klass_name :string(255)      not null
#  model      :string(255)      not null
#  company_id :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class Form < ApplicationRecord
  include UUIDHelper, SoftDeletable, TemplateClonable
  # include Forms::Generators::Contracts::ModelHelpers::Form
  # include Forms::Generators::Filters::ModelHelpers::Form

  belongs_to :company, optional: true
  has_many :sections, class_name: 'FormSection', dependent: :destroy
  has_many :entities, class_name: "FormEntity"
  has_many :choice_dependencies, class_name: 'FormChoiceDependency'
  has_many :conditions, class_name: 'FormCondition'
  has_many :validations, class_name: 'FormEntityValidation'

  def find_entity(entity_path)
    entity_path = entity_path.to_s
    entities.each do |entity|
      return entity if entity.entity_path == entity_path
    end
    sections.each do |section|
      entity = section.find_entity(entity_path)
      return entity if entity.present?
    end

    nil
  end

  def form_klass
    Object.const_get(klass_name) if klass_name.present?
  end

  def contract(user)
    Forms::Contracts::Builders::Form.(self, user)
  end

  def as_json(options = {})
    {
        id: id,
        sections: sections
    }
  end

  def model
    Object.const_get(super()) if super()
  end

end
