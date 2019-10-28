class Form < ApplicationRecord
  include UUIDHelper, SoftDeletable

  has_many :sections, class_name: 'FormSection', dependent: :destroy

end
