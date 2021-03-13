# == Schema Information
#
# Table name: custom_field_selections
#
#  id                    :bigint           not null
#  uuid                  :string(36)       not null, primary key
#  form_entity_choice_id :string(255)
#  form_custom_field_id  :string(255)
#  deleted_at            :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class CustomFieldSelection < ApplicationRecordBackwardCompatibility
  include SoftDeletable, UUIDHelper

  belongs_to :company, optional: true
  belongs_to :form_custom_field, optional: true
  belongs_to :form_entity_choice, optional: true
end
