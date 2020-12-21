# == Schema Information
#
# Table name: form_custom_fields
#
#  id             :bigint           not null
#  uuid           :string(36)       not null, primary key
#  document_type  :string(255)
#  document_id    :string(255)
#  form_id        :string(255)      not null
#  form_entity_id :string(255)      not null
#  field_key      :string(255)      not null
#  value          :string(255)
#  value_text     :string(255)
#  deleted_at     :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  entity_type    :string(255)
#

class FormCustomField < ApplicationRecord
  include UUIDHelper, SoftDeletable

  belongs_to :form
  belongs_to :form_entity
  belongs_to :document, polymorphic: true

  has_one :selection, class_name: 'CustomFieldSelection'
  has_many :selections, class_name: 'CustomFieldSelection'
  has_many :attachments, class_name: 'CustomFieldAttachment'
  # has_many :attachments, as: :resource

  def retrieve_value
    if entity_type.present?
      field_type = entity_type
    else
      field_type = FormEntity.unscoped.where(uuid: self.form_entity_id)&.first.entity_type
    end
    # FormEntity.where(uuid: self.form_entity_id)

    case field_type
    when 'text'
      value || value_text
    when 'dropdown'
      selection&.form_entity_choice&.id
      # selection&.form_entity_choice&.name
    when 'multiselect'
      selections.map(&:form_entity_choice).map(&:name)
    when 'attachment'
      attachments.as_json if self.persisted?
    else
      value
    end
  end

end


# value
# attachments
# values
