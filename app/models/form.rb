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
  include UUIDHelper, SoftDeletable
  include Forms::Generators::Contracts::ModelHelpers::Form
  include Forms::Generators::Filters::ModelHelpers::Form

  belongs_to :company
  has_many :sections, class_name: 'FormSection', dependent: :destroy
  has_many :entities, class_name: "FormEntity"
  has_many :choice_dependencies, class_name: 'FormChoiceDependency'
  has_many :conditions, class_name: 'FormCondition'
  has_many :validations, class_name: 'FormEntityValidation'

  amoeba do
    clone [:sections, :conditions, :validations]
    nullify :company_id
    nullify :uuid
    nullify :created_at
    nullify :updated_at
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
