class Docs::Trips::Contracts::Create < Forms::Contracts::Builder

  form Docs::Trips::Form
  property :company_id, validates: {presence: true}
  property :created_by_id, validates: {presence: true}
  property :status_id, deserializer: -> (input, represented, **) {represented.status_id = TripStatus.id_for(:draft)}
  property :trip_id, writable: false
  property :policy_id
  property :start_date
  property :end_date
  property :purpose
  property :trip_type_id
  collection :passengers, populate_if_empty: TripPassenger do
    property :uuid, writeable: false
    property :name
    property :contact_number
    property :email
  end
  collection :routes, populate_if_empty: TripRoute do
    property :uuid
    property :from_location
    property :to_location
    property :require_transport
    property :require_hotel
    property :require_local_conveyance
  end
  collection :transport_requests, populate_if_empty: TripTransportRequest do
    property :uuid
    property :trip_route
    property :mode
    property :depart_on
    property :preferred_timeframe
    property :budget, populate_if_empty: Amount do
      property :value
      property :currency_id
    end
    property :description
  end
  collection :hotel_requests, populate_if_empty: TripHotelRequest do
    property :uuid
    property :trip_route
    property :preferred_location
    property :checkin_at
    property :checkout_at
    property :budget, populate_if_empty: Amount do
      property :value
      property :currency_id
    end
    property :description
  end
  collection :local_conveyance_requests, populate_if_empty: TripLocalConveyanceRequest do
    property :uuid
    property :trip_route
    property :pickup_location
    property :pickup_at
    property :drop_at
    property :budget, populate_if_empty: Amount do
      property :value
      property :currency_id
    end
    property :description
  end

end