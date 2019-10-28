class FormSection < ApplicationRecord
  include UUIDHelper, SoftDeletable

  belongs_to :company
  belongs_to :form
  has_many :entities, class_name: 'FormEntity', dependent: :destroy
end
