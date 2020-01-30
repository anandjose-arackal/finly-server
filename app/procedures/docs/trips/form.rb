class Docs::Trips::Form < Forms::API

  model Trip

  section :header do
    auto_number :trip_id, sequence: {prefix: "TRF/{{\"now\" | date: \"%y-%m\" }}/", start_at: '000001'}
    reference :created_by, required: true, visible: false, can_visible_be_changed: false, class_name: 'User'
    reference :company, required: true, visible: false, can_visible_be_changed: false, class_name: 'Company', internal: true
    # dropdown :department_id, scope: Forms::Entity::Scope::AutoComplete('departments', filters: {}), required: true
    # dropdown :location_id, scope: Forms::Entity::Scope::AutoComplete('locations', filters: {}), required: true
    # dropdown :cost_center_id, scope: Forms::Entity::Scope::AutoComplete('cost_centers', filters: {}), required: true
    dropdown :status_id, scope: Forms::Entity::Scope::Enum(TripStatus, :id, :name), required: true
    dropdown :trip_type_id, scope: Forms::Entity::Scope::Enum(TripType, :id, :name), required: true
    dropdown :policy_id, scope: Forms::Entity::Scope::AutoComplete('policies', filters: {}), required: true
    date :start_date, required: true
    date :end_date, required: true
    text :purpose, required: true
  end

  section :passengers do
    collection :passengers, minimum: 1 do
      text :name, required: true
      text :contact_number
      text :email
    end
  end

  section :routes do
    collection :routes, minimum: 1 do
      text :from_location, required: true
      text :to_location, required: true
      date :depart_on, required: true
      date :return_on
      boolean :require_transport, default_value: false
      boolean :require_hotel, default_value: false
      boolean :require_local_conveyance, default_value: false
    end
  end

  section :transport_requests do
    collection :transport_requests do
      text :from_location, required: true
      text :to_location, required: true
      dropdown :mode, scope: Forms::Entity::Scope::List({value: "Flight"}), required: true
      datetime :depart_on, required: true
      dropdown :preferred_timeframe, required: true, scope: Forms::Entity::Scope::List(
          {value: "6am to 9am"}, {value: "9am to 12pm"}, {value: "12pm to 3pm"},
          {value: "3pm to 6pm"}, {value: "6pm to 9pm"}, {value: "9pm to 12am"},
          {value: "12am to 3am"}, {value: "3am to 6am"}
      )
      amount :budget, required: true
      large_text :description
    end
  end

  section :hotel_requests do
    collection :hotel_requests do
      text :location, required: true
      text :preferred_area, required: true
      datetime :checkin_at, required: true
      datetime :checkout_at, required: true
      amount :budget, required: true
      large_text :description
    end
  end

  section :local_conveyance_requests do
    collection :local_conveyance_requests do
      text :location, required: true
      text :pickup_area, required: true
      datetime :pickup_at, required: true
      datetime :drop_at, required: true
      amount :budget, required: true
      large_text :description
    end
  end

end