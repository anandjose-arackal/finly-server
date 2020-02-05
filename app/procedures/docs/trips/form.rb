class Docs::Trips::Form < Forms::API

  model Trip

  section :header, associate_custom_fields: true do
    auto_number :trip_id, sequence: {prefix: "TRF/{{\"now\" | date: \"%y-%m\" }}/", start_at: '000001'}
    dropdown :created_by, required: true, visible: false#, class_name: 'User'
    dropdown :company, required: true#, class_name: 'Company', internal: true
    # lookup :department_id, scope: Forms::Entity::Scope[:auto_complete].scope('departments', filters: {}), required: true
    # lookup :location_id, scope: Forms::Entity::Scopes::AutoComplete.scope('locations', filters: {}), required: true
    # lookup :cost_center_id, scope: Forms::Entity::Scopes::AutoComplete.scope('cost_centers', filters: {}), required: true
    dropdown :status_id, scope: Forms::Entity::Scope[:enum].scope(TripStatus, :id, :name), required: true, default_value: 1
    dropdown :trip_type_id, scope: Forms::Entity::Scope[:enum].scope(TripType, :id, :name), required: true
    dropdown :policy_id, scope: Forms::Entity::Scope[:auto_complete].scope('policies', filters: {}), required: true
    date :start_date, required: true
    date :end_date, required: true
    text :purpose, required: true
  end

  section :passengers do
    collection :passengers, populate_if_empty: TripPassenger, minimum: 1, associate_custom_fields: true do
      text :name, required: true
      text :contact_number
      text :email
    end
  end

  section :routes do
    collection :routes, populate_if_empty: TripRoute, minimum: 1, associate_custom_fields: true do
      text :from_location, required: true
      text :to_location, required: true
      date :depart_on, required: true
      date :return_on
      checkbox :require_transport, default_value: false
      checkbox :require_hotel, default_value: false
      checkbox :require_local_conveyance, default_value: false
    end
  end

  section :transport_requests do
    collection :transport_requests, populate_if_empty: TripTransportRequest, associate_custom_fields: true do
      text :from_location, required: true
      text :to_location, required: true
      dropdown :mode, scope: Forms::Entity::Scopes::List.scope({value: "Flight"}), required: true
      datetime :depart_on, required: true
      dropdown :preferred_timeframe, required: true, scope: Forms::Entity::Scopes::List.scope(
          {value: "6am to 9am"}, {value: "9am to 12pm"}, {value: "12pm to 3pm"},
          {value: "3pm to 6pm"}, {value: "6pm to 9pm"}, {value: "9pm to 12am"},
          {value: "12am to 3am"}, {value: "3am to 6am"}
      )
      amount :budget, required: true
      large_text :description
    end
  end

  section :hotel_requests do
    collection :hotel_requests, populate_if_empty: TripHotelRequest, associate_custom_fields: true do
      text :location, required: true
      text :preferred_area, required: true
      datetime :checkin_at, required: true
      datetime :checkout_at, required: true
      amount :budget, required: true
      large_text :description
    end
  end

  section :local_conveyance_requests do
    collection :local_conveyance_requests, populate_if_empty: TripLocalConveyanceRequest, associate_custom_fields: true do
      text :location, required: true
      text :pickup_area, required: true
      datetime :pickup_at, required: true
      datetime :drop_at, required: true
      amount :budget, required: true
      large_text :description
    end
  end

  dependency(
      {
          controlling_field: 'status_id',
          dependent_field: 'transport_requests/preferred_timeframe',
          dependency_mappings: [
              {
                  controlling_choice: 'draft',
                  required: false, editable: true, visible: true,
                  choices: ['6am to 9am']
              }
          ]
      }
  )

end