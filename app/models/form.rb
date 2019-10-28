class Form < ApplicationRecord
  include UUIDHelper

  has_many :sections, class_name: 'FormSection'

end
