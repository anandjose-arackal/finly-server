# == Schema Information
#
# Table name: trip_hotel_requests
#
#  id                 :bigint           not null
#  uuid               :string(36)       not null, primary key
#  trip_id            :string(255)      not null
#  trip_route_id      :string(255)      not null
#  created_by_id      :integer          not null
#  traveller_id       :integer          not null
#  company_id         :bigint
#  preferred_location :string(255)
#  checkin_at         :datetime
#  checkout_at        :datetime
#  description        :text(65535)
#  budget_id          :integer
#

class TripHotelRequest < ApplicationRecord
  include UUIDHelper

  belongs_to :trip, optional: true
  belongs_to :trip_route, optional: true
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :traveller, class_name: 'User', optional: true
  belongs_to :company, optional: true
  belongs_to :budget, class_name: 'Amount', optional: true
end
