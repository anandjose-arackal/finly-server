# == Schema Information
#
# Table name: trip_hotel_requests
#
#  id             :bigint           not null
#  uuid           :string(36)       not null, primary key
#  trip_id        :string(255)
#  created_by_id  :integer
#  traveller_id   :integer
#  company_id     :bigint
#  location       :string(255)
#  preferred_area :string(255)
#  checkin_at     :datetime
#  checkout_at    :datetime
#  description    :text(65535)
#  budget_id      :integer
#  deleted_at     :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class TripHotelRequest < ApplicationRecord
  include SoftDeletable
  include UUIDHelper

  belongs_to :trip, optional: true
  belongs_to :trip_route, optional: true
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :traveller, class_name: 'User', optional: true
  belongs_to :company, optional: true
  belongs_to :budget, class_name: 'Amount', optional: true

  has_many :custom_fields, as: :document, class_name: "FormCustomField", primary_key: :uuid

  def as_json(options = {})
    {
        id: id,
        location: location,
        preferred_area: preferred_area,
        checkin_at: checkin_at,
        checkout_at: checkout_at,
        description: description,
        budget: budget
    }
  end
end
