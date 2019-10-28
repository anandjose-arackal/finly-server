class FormEntityChoice < ApplicationRecord
  include SoftDeletable, UUIDHelper

  belongs_to :company
  belongs_to :form
  belongs_to :form_section
  belongs_to :form_entity
  belongs_to :created_by_user, class_name: 'User', optional: true

end
