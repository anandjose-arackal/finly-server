# == Schema Information
#
# Table name: form_sections
#
#  id           :bigint           not null
#  uuid         :string(36)       not null, primary key
#  name         :string(255)      not null
#  form_id      :integer          not null
#  company_id   :integer          not null
#  active       :boolean          default(TRUE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  section_type :string(255)
#

class FormSection < ApplicationRecord
  include UUIDHelper, SoftDeletable

  belongs_to :company
  belongs_to :form
  has_many :entities, class_name: 'FormEntity', dependent: :destroy

  def as_json(options = {})
    {
        id: id,
        name: name,
        active: active,
        type: section_type,
        form_id: form_id,
        entities: entities
    }
  end
end
