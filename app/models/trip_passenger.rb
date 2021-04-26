# == Schema Information
#
# Table name: trip_passengers
#
#  id             :bigint           not null
#  uuid           :string(36)       not null, primary key
#  trip_id        :string(255)
#  name           :string(255)
#  contact_number :string(255)
#  email          :string(255)
#  deleted_at     :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class TripPassenger < ApplicationRecord
  include SoftDeletable
  include UUIDHelper

  belongs_to :company, optional: true
  belongs_to :trip

  has_many :custom_fields, as: :document, class_name: "FormCustomField", primary_key: :uuid

  def as_json(options = {})
    {
        id: id,
        name: name,
        contact_number: contact_number,
        email: email
    }
  end

end
