class FormCustomField < ApplicationRecord
  include UUIDHelper

  belongs_to :form
  belongs_to :form_entity
  belongs_to :document, polymorphic: true
end
