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

  belongs_to :company, optional: true
  belongs_to :form
  belongs_to :form_entity
  belongs_to :document, polymorphic: true
end
