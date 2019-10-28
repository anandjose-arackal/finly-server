class FormSection < ApplicationRecord
  include UUIDHelper

  belongs_to :form
  has_many :entities, class_name: "FormEntity"
end
