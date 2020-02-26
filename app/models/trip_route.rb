# == Schema Information
#
# Table name: trip_routes
#
#  id                       :bigint           not null
#  uuid                     :string(36)       not null, primary key
#  trip_id                  :string(255)
#  from_location            :string(255)
#  to_location              :string(255)
#  depart_on                :date
#  return_on                :date
#  require_transport        :boolean          default(FALSE)
#  require_hotel            :boolean          default(FALSE)
#  require_local_conveyance :boolean          default(FALSE)
#  deleted_at               :datetime
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class TripRoute < ApplicationRecord
  include SoftDeletable
  include UUIDHelper

  belongs_to :trip

  has_many :custom_fields, as: :document, class_name: "FormCustomField", primary_key: :uuid

  def as_json(options = {})
    {
        id: id,
        from_location: from_location,
        to_location: to_location,
        depart_on: depart_on,
        return_on: return_on,
        require_transport: require_transport,
        require_hotel: require_hotel,
        require_local_conveyance: require_local_conveyance
    }
  end
end
