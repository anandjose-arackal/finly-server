class CustomFieldSelection < ApplicationRecord
  include SoftDeletable, UUIDHelper

  belongs_to :form_custom_field, optional: true
  belongs_to :form_entity_choice, optional: true
end
