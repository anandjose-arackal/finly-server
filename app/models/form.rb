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
#  deleted_at :datetime
#

class Form < ApplicationRecord
  include UUIDHelper, SoftDeletable
  include Forms::Generators::Contracts::ModelHelpers::Form
  include Forms::Generators::Filters::ModelHelpers::Form

  belongs_to :company
  has_many :sections, class_name: 'FormSection', dependent: :destroy
  has_many :entities, class_name: "FormEntity"
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

end
