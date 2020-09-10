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
#

class FormCustomField < ApplicationRecord
  include UUIDHelper

  belongs_to :form
  belongs_to :form_entity
  belongs_to :document, polymorphic: true

  has_one :selection, class_name: 'CustomFieldSelection'
  has_many :selections, class_name: 'CustomFieldSelection'
  has_many :attachments, class_name: 'CustomFieldAttachment'

  def value(value=nil)
    self.value = value if value.present?

    case self.form_entity&.entity_type
    when 'text'
      value_text
    when 'dropdown'
      selection&.form_entity_choice&.name
    when 'multiselect'
      selections.map(&:form_entity_choice).map(&:name)
    when 'attachment'
      attachments.as_json if self.persisted?
    else
      super()
    end
  end
end


# value
# attachments
# values
