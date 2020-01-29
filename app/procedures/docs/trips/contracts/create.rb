class Docs::Trips::Contracts::Create < Forms::Contracts::Builder

  form Docs::Trips::Form
  user_scope :created_by

  property :company, validates: {presence: true}
  property :created_by, validates: {presence: true}
  property :status_id, deserializer: -> (input, represented, **) { represented.status_id = TripStatus.id_for(:draft) }
  property :trip_id, writable: false
  property :policy_id
  property :start_date
  property :end_date
  property :purpose, form: {scope: Forms::Entity::Scope::List({value: "a", name: "a"})}
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
    property :depart_on
    property :return_on
    property :require_transport
    property :require_hotel
    property :require_local_conveyance
  end
  collection :transport_requests, populate_if_empty: TripTransportRequest do
    property :uuid
    property :from_location
    property :to_location
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
    property :location
    property :preferred_area
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
    property :location
    property :pickup_area
    property :pickup_at
    property :drop_at
    property :budget, populate_if_empty: Amount do
      property :value
      property :currency_id
    end
    property :description
  end

  functions do
    validate :route_to_request_validation

    def route_to_request_validation
      verified_requests = []
      routes.each do |route|
        validate_transport(route, verified_requests)
        validate_hotel(route, verified_requests)
        validate_local_conveyance(route, verified_requests)
      end

      if (invalid_requests = transport_requests - verified_requests).present?
        invalid_requests.each do |request|
          errors.add :base, "Transport Request from #{request.from_location} to #{request.to_location} on #{request.depart_on} is not valid"
        end
      end

      if (invalid_requests = hotel_requests - verified_requests).present?
        invalid_requests.each do |request|
          errors.add :base, "Hotel Request in #{request.location} on #{request.checkin_at} is not valid"
        end
      end

      if (invalid_requests = local_conveyance_requests - verified_requests).present?
        invalid_requests.each do |request|
          errors.add :base, "Local Conveyance Request in #{request.location} on #{request.pickup_at} is not valid"
        end
      end
    end

    def validate_transport(route, verified_requests)
      return unless route.require_transport

      valid = false
      transport_requests.each do |request|
        next if verified_requests.include?(request)
        next unless request.from_location == route.from_location
        next unless request.to_location == route.to_location
        next unless request.depart_on == route.depart_on
        verified_requests << request
        valid = true
        break
      end
      unless valid
        errors.add :base, "Transport Request from #{route.from_location} to #{route.to_location} not found"
      end
    end

    def validate_hotel(route, verified_requests)
      return unless route.require_hotel

      valid = false
      hotel_requests.each do |request|
        next if verified_requests.include?(request)
        next unless request.location == route.to_location
        verified_requests << request
        valid = true
        break
      end
      unless valid
        errors.add :base, "Hotel Request in #{route.from_location} not found"
      end
    end

    def validate_local_conveyance(route, verified_requests)
      return unless route.require_local_conveyance

      valid = false
      local_conveyance_requests.each do |request|
        next if verified_requests.include?(request)
        next unless request.location == route.to_location
        verified_requests << request
        valid = true
        break
      end
      unless valid
        errors.add :base, "Local Conveyance Request in #{route.from_location} not found"
      end
    end

  end

end