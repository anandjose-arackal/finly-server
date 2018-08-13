json.travel_request @result.travel_request

json.manager_name @result.manager&.name
json.travel_manager_name @result.travel_manager&.name
json.controlling_user_name @result.travel_request&.controlling_user&.name
json.owner do
  owner = @result.travel_request.user
  json.first_name owner.first_name
  json.last_name owner.last_name
  json.gender owner.profile.gender
  json.age DateUtils.age(owner.profile.date_of_birth)
  json.salutation owner.profile.salutation_status
  json.email owner.email
  json.mobile_number owner.mobile_number
end

json.destinations do
  json.array! @result.destinations do |destination|
    json.extract! destination, :id, :location
    json.booking @result.grouped_bookings(destination)
  end
end

json.actions @result.actions
json.policies @result.travel_request.user.policies
json.editable @result.editable
json.destroyable @result.destroyable
json.can_select_options @result.can_select_options?
json.can_add_request @result.can_add_request?
json.can_add_options @result.can_add_options?
json.can_add_booking @result.can_add_booking?
json.can_cancel_booking @result.can_cancel_booking?
json.can_create_money_requests @result.can_create_money_requests?
json.show_money_requests @result.show_money_requests?
json.can_create_reports @result.can_create_reports?
json.show_reports @result.show_reports?

json.money_requests do
  json.array! @result.money_requests.each do |money_request|
    json.extract! money_request, :id, :name, :memo, :required_by_date
    json.status money_request.status
    json.user do
      json.extract! money_request.user, :name
    end
    json.policy money_request.policy.name if money_request.policy
    json.submitted_amount money_request.submitted_amount
    json.processed_amount money_request.processed_amount
    json.submitted_on DateUtils.date_formatted money_request.submitted_at
  end
end

json.reports do
  json.array! @result.reports.each do |report|
      json.extract! report, :id, :name
      json.submitted_on DateUtils.date_formatted report.submitted_at
      json.user do
        json.extract! report.user, :name
      end
      if report.memo
        if report.memo[21]
          json.memo report.memo[0, 20] + "..."
        else
          json.memo report.memo
        end
      end
      if report.policy
        json.policy report.policy.name
      end
      json.status report.report_status
      json.total(('%.2f' % report.total_amount))
      json.currency report.base_currency
  end
end



json.comments do
  json.array!(@result.travel_request.comments) do |comment|
    json.content comment.retrieve_content(current_user)
    json.user_name comment.user&.name
    json.timestamp comment.created_at.strftime('%d %b %Y')
    json.initials comment.user&.initials
  end
end