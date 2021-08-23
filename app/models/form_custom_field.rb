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

  belongs_to :company, optional: true
  belongs_to :form
  belongs_to :form_entity
  belongs_to :document, polymorphic: true

  has_one :selection, class_name: 'CustomFieldSelection'
  has_many :selections, class_name: 'CustomFieldSelection'
  has_many :attachments, class_name: 'CustomFieldAttachment'
  # has_many :attachments, as: :resource


  def selected_choice
    if entity_type == 'dropdown'
      return selection&.form_entity_choice&.name
    end
    value
  end

  def retrieve_value
    if entity_type.present?
      field_type = entity_type
    else
      field_type = FormEntity.include_soft_deleted.where(uuid: self.form_entity_id)&.first.entity_type
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
    when 'switch'
      FormEntity::Switch::TRUTHY_VALUES.include? value
    when 'number'
      form_entity.options['format'] == 'number' ? value.to_i.to_s :  sprintf( "%0.02f", value.to_f)
    when 'date'
      value.present? ? value.to_datetime.strftime('%Y-%m-%d') : value
    when 'datetime'
      value.present? ? value.to_datetime.strftime('%Y-%m-%d %H:%M:%S') : value
    else
      value
    end
  end

  # temporarily  added to get text value against custom field
  # to support in macro
  def retrieve_text_value
    if entity_type.present?
      field_type = entity_type
    else
      field_type = FormEntity.include_soft_deleted.where(uuid: self.form_entity_id)&.first.entity_type
    end
    # FormEntity.where(uuid: self.form_entity_id)

    case field_type
    when 'text'
      value || value_text
    when 'dropdown'
      selection&.form_entity_choice&.name
    when 'multiselect'
      selections.map(&:form_entity_choice).map(&:name)
    when 'attachment'
      if self.persisted?
        (attachments.as_json.map do |att_json|
          att_json[:url]
        end).join("\n")
      end
    when 'number'
      form_entity.options['format'] == 'number' ? value.to_i.to_s :  sprintf( "%0.02f", value.to_f)
    when 'date'
      value.present? ? value.to_datetime.strftime('%Y-%m-%d') : value
    when 'datetime'
      value.present? ? value.to_datetime.strftime('%Y-%m-%d %H:%M:%S') : value
    when 'switch'
      FormEntity::Switch::TRUTHY_VALUES.include? value
    else
      value
    end
  end

end


# value
# attachments
# values
