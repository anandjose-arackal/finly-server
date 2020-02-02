# == Schema Information
#
# Table name: forms
#
#  id         :bigint           not null
#  uuid       :string(36)       not null, primary key
#  klass_name :string(255)      not null
#  model      :string(255)      not null
#  company_id :integer          not null
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Form < ApplicationRecord
  include UUIDHelper, SoftDeletable

  has_many :sections, class_name: 'FormSection', dependent: :destroy
  has_many :entities, through: :sections
  has_many :dependencies, class_name: 'FormDependency'

  def as_json(options = {})
    {
        id: id,
        sections: sections
    }
  end

  def model
    Object.const_get(super()) if super()
  end

  def contract
    sections = self.sections.includes(entities: {entities: {entities: {entities: [:entities]}}})
    dependencies = self.dependencies
    Class.new(Forms::Contract) do
      sections.each do |section|
        section.entities.root.each do |entity|
          instance_eval &entity.contract
        end
      end

      dependencies.each do |dependency|
        class_eval &dependency.contract
      end
    end
  end
end
