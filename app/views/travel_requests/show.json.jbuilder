json.extract! @result.travel_request, :id, :name, :policy_id, :required_by_date,
              :note,
              :user_id, :controlling_user_id,
              :controlling_for_user_id, :controlling_user_role, :controlling_for_user_role,
              :submitted_at, :created_at, :updated_at
json.status do
  json.extract! @result.travel_request.status, :id, :name
end

json.destinations do
  json.array! @result.destinations do |destination|
    json.extract! destination, :id, :name, :source
    json.booking_requests do
      json.array! destination.booking_requests do |booking_request|
        json.extract! booking_request, :id, :booking_type_id
        json.booking_type_name booking_request.booking_type.name
        if booking_request.flight?
          json.booking_flight do
            json.extract! booking_request.booking_flight, :id, :departure_date, :journey_destination, :journey_source
          end
        end

        if booking_request.bus?
          json.booking_bus do
            json.extract! booking_request.booking_bus, :id, :journey_source, :journey_destination, :journey_date
          end
        end

        if booking_request.train?
          json.booking_train do
            json.extract! booking_request.booking_train, :id, :journey_source, :journey_destination, :journey_date
          end
        end

        if booking_request.train?
          json.booking_train do
            json.extract! booking_request.booking_train, :id, :journey_source, :journey_destination, :journey_date
          end
        end
      end
    end
  end
end

