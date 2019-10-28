class FormEntity < ApplicationRecord
  include SoftDeletable, UUIDHelper

  belongs_to :company
  belongs_to :form_section
  belongs_to :form
  belongs_to :parent, class_name: 'FormEntity', optional: true

  has_many :choices, class_name: 'FormEntityChoice', dependent: :destroy

  accepts_nested_attributes_for :choices

  serialize :options, JSON
  serialize :chained, JSON
  serialize :data_provider, JSON
end
