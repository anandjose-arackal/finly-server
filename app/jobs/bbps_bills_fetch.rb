class BbpsBillsFetch < ApplicationJob

  def perform
    # Fetch bills where automatic fetching is enabled
    status_ids = BbpsBillerSubscription.status_ids(:approved, :auto_approved, :reactivated)
    bbps_subscriptions = BbpsBillerSubscription.where(status_id: status_ids, auto_generate_bill: true).where(expected_bill_day: nil)
    autofetched = true

    bbps_subscriptions.each do |subscription|
      last_bill = subscription.bbps_bills.reorder('created_at asc').last
      will_create = false

      if last_bill.present?
        if last_bill.bill_date.present? && last_bill.bill_date != Date.parse('01-01-0001')
          if Date.today > (last_bill.bill_date + 30.days)
            will_create = true
          end
        else
          date = last_bill.created_at + 21.days
          if Date.today >= date
            will_create = true
          end
        end
      else
        will_create = true
      end


      if will_create
        parameters = customer_params(subscription).with_indifferent_access
        Bbps::BillFetch.call_async({params: parameters, "current_user" => User.first}, wait: true) do |op|
          op.success do |result|
            ap result
            create_bill(result, subscription, autofetched)
          end
          op.error {|result| ap result}
          op.failure {|result| ap result}
        end
      end
    end

    # Where Auto Fetching Bills not supported by vendors
    # Create bills two days before expected bill day
    autofetched = false
    bill_day = (Date.today + 2.days).day
    bbps_subscriptions = BbpsBillerSubscription.where(status_id: status_ids, auto_generate_bill: true).where(expected_bill_day: bill_day)
    bbps_subscriptions.each {|subscription| create_bill({}, subscription, autofetched)}
  end

  def create_bill(result, subscription, autofetched)
    if autofetched
      return unless result.status == 'Y'
      return if result.ref_no.blank?
      amount = (result.amount.to_f / 100).round(2)

      # Skipping bill creation if amount is zero
      return if amount.to_i <= 0

      bill_date_year = Date.parse(result.bill_date).strftime("%Y")
      bill_period = result.bill_period
      bill = nil

      if (result.due_date.present? && result.due_date != "NA" && result.due_date != "9999-01-01") && (result.bill_date.present? && result.bill_date != "NA" && result.bill_date != "0001-01-01")
        bill = subscription.bbps_bills.where("bill_date = ? AND due_date = ?", Date.parse(result.bill_date), Date.parse(result.due_date)).first
      elsif result.due_date.present? && result.due_date != "NA" && result.due_date != "9999-01-01"
        bill = subscription.bbps_bills.where("due_date = ?", Date.parse(result.due_date)).first
      elsif result.bill_date.present? && result.bill_date != "NA" && result.bill_date != "0000-01-01"
        bill = subscription.bbps_bills.where("bill_date = ?", Date.parse(result.bill_date)).first
      elsif result.bill_period.present? && result.bill_period != "NA"
        # Received the following kinds of bill numbers
        # ["1", nil, "december", "march", "may", "Monthly", "JANUARY", "MONTHLY", "FEBRUARY", "0.0", "JAN 20", "202002", "DECEMBER"]

        if bill_periods.include?(bill_period.to_s.downcase) # Deals with Months
          bill = subscription.bbps_bills.where(bill_period: result.bill_period).first
        elsif ["monthly"].includes?(bill_period.to_s.downcase) # Deals with Monthly; Also changes it to current month
          bill_period = Date.today.strftime("%b")
          bill = subscription.bbps_bills.where(bill_period: result.bill_period).first
        elsif bill_periods.filter {|month| period.downcase.index(month)}.present? # Deals with 'JAN 20'
          bill_period = bill_periods.filter {|month| period.downcase.index(month)}[0]
          bill = subscription.bbps_bills.where(bill_period: result.bill_period).first
        else
          # bill = subscription.bbps_bills.where("extract(year from created_at) = ?", Date.today.strftime("%Y")).where("extract(month from created_at) = ?", Date.today.strftime("%b"))
          Event::EAlert::Create.(nil,
              title: "Ambiguous Bill Creation #{subscription.id} . #{bill&.id}",
              description: "Subscription: #{subscription.as_json} \n Bills: #{subscription.bbps_bills.last.as_json} \n Response: #{result.as_json["table"]}",
              subject: "Ambiguous Bill Creation #{subscription.id} . #{bill&.id}"
          )
        end
      else
        Event::EAlert::Create.(nil,
            title: "Ambiguous Bill Creation #{subscription.id} . #{bill&.id}",
            description: "Subscription: #{subscription.as_json} \n Bills: #{subscription.bbps_bills.last.as_json} \n Response: #{result.as_json["table"]}",
            subject: "Ambiguous Bill Creation #{subscription.id} . #{bill&.id}"
        )
      end


      # Do not create bill if bill for same year and period exists
      # Update bill's reference number
      if bill.present?
        bill.update(order_number: result.ref_no, order_number_type: "BillFetch")
        return
      end

      bill_period = Date.today.strftime("%B").upcase if bill_period == "NA"


      params = {
          amount: (result.amount.to_f / 100).round(2),
          bill_date: result.bill_date,
          bill_number: result.bill_number,
          due_date: result.due_date,
          bill_period: bill_period,
          convenience_fee: get_amount_from_response(result.convenience_fee),
          convenience_fee_desc: result.convenience_fee_desc,
          early_payment_fee: get_amount_from_response(result.early_payment_fee),
          late_payment_fee: get_amount_from_response(result.late_payment_fee),
          subscription_id: subscription.id,
          autofetched: autofetched,
          order_number: result.ref_no,
          order_number_type: "BillFetch"
      }
      op = Docs::UtilityBills::Bills::Ops::Create.(params: params, current_user: User.first)
      if op.success?
        new_bill = op['model']
        Docs::UtilityBills::Bills::Mailers::New::Autofetched.(params: {record: new_bill}, current_user: User.first)
      end
    else
      params = {
          amount: 0,
          bill_date: subscription.expected_bill_day,
          bill_period: Date.today.strftime("%B"),
          convenience_fee: 0,
          convenience_fee_desc: 0,
          early_payment_fee: 0,
          late_payment_fee: 0,
          subscription_id: subscription.id,
          autofetched: autofetched
      }
      op = Docs::UtilityBills::Bills::Ops::Create.(params)
      if op.success?
        new_bill = op['model']
        Docs::UtilityBills::Bills::Mailers::New::Manual.(params: {record: new_bill}, current_user: User.first)
      end
    end
  end

  def get_amount_from_response(response)
    return response.to_f unless response.to_s.include?("=")
    response.to_s.split("=")[1].to_f / 100
  end

  def customer_params(subscription)
    parameters = {
        mobile_number: subscription.mobile_number,
        biller_id: subscription.biller&.biller_id,
    }

    (1..5).to_a.each do |i|
      key = subscription.send("customer_param_key_#{i}")
      value = subscription.send("customer_param_value_#{i}")
      if key.present? && value.present?
        parameters["customer_param_#{i}"] = {
            key: key,
            value: value
        }
      end
    end

    parameters
  end

  def get_bill_period(bill_period)
    if bill_periods.include?(bill_period.to_s.downcase)
      bill_period
    elsif ["monthly"].includes?(bill_period.to_s.downcase)
      Date.today.strftime("%b")
    else
      bill_periods.each {|month| return month if period.downcase.index(month)}

    end

  end

  def bill_periods
    ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec", "january", "february", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december"]
  end
end
