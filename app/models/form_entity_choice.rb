# == Schema Information
#
# Table name: form_entity_choices
#
#  id                 :bigint           not null
#  uuid               :string(36)       not null, primary key
#  company_id         :integer          not null
#  form_id            :string(36)       not null
#  form_section_id    :string(36)       not null
#  form_entity_id     :string(36)       not null
#  created_by_user_id :integer
#  name               :string(255)      not null
#  position           :integer          not null
#  active             :boolean          default(TRUE)
#  deleted_at         :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class FormEntityChoice < ApplicationRecord
  include SoftDeletable, UUIDHelper

  belongs_to :company
  belongs_to :form
  belongs_to :form_section
  belongs_to :form_entity
  belongs_to :created_by_user, class_name: 'User', optional: true

  def as_json(options = {})
    {
        id: uuid,
        value: value,
        position: position,
        active: active,
    }
  end

end
