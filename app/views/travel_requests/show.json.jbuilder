json.extract! @result.travel_request, :id, :name, :policy_id, :required_by_date,
              :note,
              :user_id, :controlling_user_id,
              :controlling_for_user_id, :controlling_user_role, :controlling_for_user_role,
              :submitted_at, :created_at, :updated_at

json.policy do
  json.id @result.travel_request.policy_id
  json.name @result.travel_request.policy&.name
end
json.status do
  json.extract! @result.travel_request.status, :id, :name
end

json.editable @result.editable

json.destroyable @result.destroyable

json.destinations do
  json.array! @result.destinations do |destination|
    json.extract! destination, :id, :name, :source
    json.booking_requests do
      json.array! destination.booking_requests do |booking_request|
        json.extract! booking_request, :id, :booking_type_id, :note
        json.booking_type_name booking_request.booking_type.name
        if booking_request.flight?
          json.booking_flight do
            json.extract! booking_request.booking_flight, :id, :journey_date, :journey_destination, :journey_source, :booking_class, :stops
          end
        end

        if booking_request.bus?
          json.booking_bus do
            json.extract! booking_request.booking_bus, :id, :journey_source, :journey_destination, :journey_date, :booking_class
          end
        end

        if booking_request.train?
          json.booking_train do
            json.extract! booking_request.booking_train, :id, :journey_source, :journey_destination, :journey_date, :booking_class
          end
        end

        if booking_request.car_rental?
          json.booking_car_rental do
            json.extract! booking_request.booking_car_rental, :id, :journey_source, :journey_destination, :journey_date,
                          :pickup_address, :pickup_time, :reservation_start_date, :reservation_end_date, :car_type
          end
        end

        if booking_request.hotel?
          json.booking_hotel do
            json.extract! booking_request.booking_hotel, :id, :reservation_destination,
                          :reservation_start_date, :reservation_end_date, :hotel_name, :hotel_rating
          end
        end

        if booking_request.restaurant?
          json.booking_restaurant do
            json.extract! booking_request.booking_restaurant, :id, :reservation_destination, :reservation_date,
                          :reservation_time, :restaurant_name, :restaurant_rating
          end
        end
        json.travel_members do
          json.array! booking_request.travel_members do |travel_member|
            json.extract! travel_member,:id, :title, :first_name, :middle_name, :last_name,
                          :child, :age, :email, :mobile_number, :gender
          end
        end
        json.bookings do
          json.array! booking_request.bookings do |booking|
            json.extract! booking, :id, :booking_type_id, :note
            json.booking_type_name booking.booking_type.name
            # json.booking_status booking&.booking_status.name&.humanize

            if booking.flight?
              json.booking_flight do
                json.extract! booking.booking_flight, :id, :departure_date, :journey_destination,
                :journey_source, :journey_date, :booking_class, :stops, :ticket_number, :pnr, :airline
              end
            end

            if booking.bus?
              json.booking_bus do
                json.extract! booking.booking_bus, :id, :journey_source, :journey_destination, :journey_date, :booking_class, :boarding_point
              end
            end

            if booking.train?
              json.booking_train do
                json.extract! booking.booking_train, :id, :journey_source, :journey_destination, :journey_date,
                :booking_class, :boarding_station_name, :pnr, :train_number
              end
            end
            if booking.car_rental?
              json.booking_car_rental do
                json.extract! booking.booking_car_rental, :id, :journey_source, :journey_destination, :journey_date,
                              :pickup_address, :pickup_time, :reservation_start_date, :reservation_end_date, :car_type, :car_number
              end
            end

            if booking.hotel?
              json.booking_hotel do
                json.extract! booking.booking_hotel, :id, :reservation_destination,
                              :reservation_start_date, :reservation_end_date, :hotel_name, :reservation_time, :hotel_rating
              end
            end

            if booking.restaurant?
              json.booking_restaurant do
                json.extract! booking.booking_restaurant, :id, :reservation_destination, :reservation_date,
                              :reservation_time, :restaurant_name, :restaurant_rating
              end
            end

            json.attachments do
              json.array! booking.attachments do |attachment|
                json.extract! attachment, :id, :description
                json.file_name attachment.attachment_file_name
                json.file_size (attachment.attachment_file_size / 1024).round(2).to_s + " KB"
                json.url attachment.attachment.url
              end
            end

            json.travel_members do
              json.array! booking.travel_members do |travel_member|
                json.extract! travel_member,:id, :title, :first_name, :middle_name, :last_name,
                              :child, :age, :email, :mobile_number, :gender
              end
            end
          end
        end
      end
    end
  end
end

json.booking_types do
  json.array! @result.booking_types do |booking_type|
    json.extract! booking_type, :id, :name
  end
end

json.user_reports current_user.reports
json.user_money_requests current_user.money_requests

json.linked_report do
  json.id @result.travel_request.report&.id
  json.name @result.travel_request.report&.name
end

json.linked_money_request do
  json.id @result.travel_request.money_request&.id
  json.name @result.travel_request.money_request&.name
end

json.actions @result.actions

json.policies current_company.policies

json.comments do
  json.array!(@result.travel_request.comments) do |comment|
    json.content comment.retrieve_content(current_user)
    json.user_name comment.user&.name
    json.timestamp comment.created_at.strftime('%d %b %Y')
    json.initials comment.user&.initials
  end
end