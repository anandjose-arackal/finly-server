# == Schema Information
#
# Table name: trip_passengers
#
#  id             :bigint           not null, primary key
#  uuid           :string(36)       not null
#  trip_id        :bigint           not null
#  name           :string(255)
#  contact_number :string(255)
#  email          :string(255)
#

class TripPassenger < ApplicationRecord
end
