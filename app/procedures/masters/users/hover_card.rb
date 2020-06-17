class Masters::Users::HoverCard < HoverCard::API

  model User
  policy Masters::Users::Policy
  policy_action :hover_card?

  json do |context, record|
    {
        id: record.id,
        name: record.name,
        email: record.email,
        mobile_number: record.mobile_number,
        location: record.location&.name,
        department: record.department&.name,
        cost_center: record.cost_center&.name,
        employee_id: record.profile&.employee_id,
        active: record.active
    }
  end

end