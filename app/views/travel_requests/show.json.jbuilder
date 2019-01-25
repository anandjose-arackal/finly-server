json.travel_request do
  request_json = @result.travel_request.as_json
  request_json.merge!({status: {id: @result.travel_request.status_id, name: @result.travel_request.status_for_user(@result.user)}})
  request_json.each do |key, value|
    json.set! key, value
  end
end

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
json.policies @result.policies.each do |policy|
  json.id policy.id
  json.name policy.name
  json.custom_fields @result.custom_fields_for(policy, :travel_request)
end
json.booking_requests_config do
  json.custom_fields @result.custom_fields_for(@result.travel_request.policy, :booking_request)
end
json.editable @result.editable
json.destroyable @result.destroyable
json.can_select_options @result.can_select_options?
json.can_add_request @result.can_add_request?
json.can_add_options @result.can_add_options?
json.can_add_booking @result.can_add_booking?
json.can_mark_as_unavailable @result.can_add_options?
json.can_cancel_booking @result.can_cancel_booking?
json.can_create_money_requests @result.can_create_money_requests?
json.show_money_requests @result.show_money_requests?
json.can_create_reports @result.can_create_reports?
json.show_reports @result.show_reports?

# json.summary @result.travel_request.summary

json.money_requests do
  json.total_submitted 0
  json.total_processed 0
  json.data do
    json.array! @result.money_requests.each do |money_request|
      json.extract! money_request, :id, :name, :memo, :required_by_date
      json.status money_request.status
      json.user do
        json.extract! money_request.user, :name
      end

      json.can_view @result.can_view_money_request?(money_request)
      json.can_edit @result.can_edit_money_request?(money_request)

      json.submitted_amount Amount.new(value: money_request.total_amount, currency: money_request.base_currency)
      json.processed_amount money_request.processed_amount
      if money_request.destination_pocket.present?
        json.destination_pocket do
          pocket = money_request.destination_pocket
          json.id pocket.id
          json.name pocket.name
          json.pocket_type do
            json.id pocket.user_pocket_type.id
            json.name pocket.user_pocket_type.name
          end
          adapter = AccountManager::CashPockets::CashPocketsAdapter.new(pocket)
          json.balance adapter.balance(display_balance: true)
          currency = pocket.base_currency
          json.base_currency do
            json.symbol currency&.symbol
            json.country_code currency&.country_code
            json.id currency&.id
          end
        end
      end

      json.request_items money_request.items do |item|
        json.category do
          json.name item.category.name
          json.id item.category.id
        end
        json.amount do
          json.value item.amount.value
          json.currency item.amount.currency
        end
      end

      json.custom_fields do
        json.array! money_request.custom_fields
      end

    end
  end
end

# For money requests
json.cash_pockets do
  json.array!(@result.travel_request.user.user_pockets.cash_pockets_only) do |pocket|
    adapter = AccountManager::CashPockets::CashPocketsAdapter.new(pocket)
    json.name pocket.name
    json.balance adapter.balance(display_balance: true)
    json.id pocket.id
    json.base_currency do
      json.symbol pocket.base_currency&.symbol
      json.country_code pocket.base_currency&.country_code
      json.id pocket.base_currency&.id
    end
  end
end

json.reports do
  # json.total_reported 0
  # json.data do
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
  # end
end


json.comments do
  json.array!(@result.travel_request.comments) do |comment|
    json.content comment.retrieve_content(current_user)
    json.user_name comment.user&.name
    json.timestamp comment.created_at.strftime('%d %b %Y')
    json.initials comment.user&.initials
  end
end

# json.custom_fields do
#   json.array! @result.travel_request.custom_fields
# end
#
json.reviewal_chains do
  json.array! @result.reviewal_chains do |chain|
    json.policy_id chain[:policy_id]
    json.reviewal_chain do
      json.array! chain[:reviewal_chain] do |item|
        json.level_number item[:level_number]
        json.level_id item[:level_id]
        if item[:selected_reviewer].present?
          json.selected_reviewer do
            json.reviewer_details item[:selected_reviewer].as_json
            json.threshold item[:selected_reviewer_threshold]
          end
        end
        json.reviewers do
          json.array! item[:reviewers] do |reviewer|
            json.extract! reviewer, :id, :exception, :threshold
            json.reviewer_details reviewer.reviewer.as_json
          end
        end
      end
    end
  end
end
json.reviewal_chain @result.travel_request.get_reviewal_chain

json.reviewal_chains_booking do
  json.array! @result.reviewal_chains_booking do |chain|
    json.policy_id chain[:policy_id]
    json.reviewal_chain do
      json.array! chain[:reviewal_chain] do |item|
        json.level_number item[:level_number]
        json.level_id item[:level_id]
        json.selected_reviewer item[:selected_reviewer]&.as_json
        json.reviewers do
          json.array! item[:reviewers] do |reviewer|
            json.extract! reviewer, :id, :exception, :threshold
            json.reviewer_details reviewer.reviewer.as_json
          end
        end
      end
    end
  end
end
json.reviewal_chain @result.travel_request.get_reviewal_chain
