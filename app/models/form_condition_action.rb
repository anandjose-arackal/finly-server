class FormConditionAction < ApplicationRecord
  include UUIDHelper

  belongs_to :company
  belongs_to :form
  belongs_to :form_condition

  def as_json(options={})
    {
        property: property,
        value: value
    }
  end
end
