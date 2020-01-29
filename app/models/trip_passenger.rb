# == Schema Information
#
# Table name: trip_passengers
#
#  id             :bigint           not null
#  uuid           :string(36)       not null, primary key
#  trip_id        :string(255)      not null
#  name           :string(255)
#  contact_number :string(255)
#  email          :string(255)
#

class TripPassenger < ApplicationRecord
  include SoftDeletable
  include UUIDHelper

  belongs_to :trip

  def as_json(options={})
    {
        id: id,
        name: name,
        contact_number: contact_number,
        email: email
    }
  end

end
