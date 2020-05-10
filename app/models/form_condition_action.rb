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
#

class FormConditionAction < ApplicationRecord
  include UUIDHelper

  belongs_to :company
  belongs_to :form
  belongs_to :form_condition

  amoeba do
    enable
    nullify :uuid
    nullify :company_id
    nullify :form_id
    nullify :created_at
    nullify :updated_at
  end

  def as_json(options={})
    {
        property: property,
        value: value
    }
  end
end
