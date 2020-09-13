# == Schema Information
#
# Table name: form_condition_actions
#
#  id                :bigint           not null
#  uuid              :string(36)       not null, primary key
#  company_id        :bigint           not null
#  form_id           :string(255)      not null
#  form_condition_id :string(255)      not null
#  property          :string(255)
#  value             :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  deleted_at        :datetime
#

class FormConditionAction < ApplicationRecord
  include UUIDHelper

  belongs_to :company
  belongs_to :form
  belongs_to :form_condition

  TRUTHY_VALUES = ["true", true, 1, "1", "TRUE"]

  def as_json(options={})
    {
        property: property,
        value: FormConditionAction::TRUTHY_VALUES.include?(value) ? true : false,
        id: id,
    }
  end
end
