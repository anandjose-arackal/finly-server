class BbpsBillsFetch

  def self.perform
    puts " ----------------------------- PERFORMING #{self.name} at #{Time.now.strftime("%d-%B-%Y %H:%M:%S")} ------------------------------"

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

    puts " ----------------------------- FINISHED #{self.name} ------------------------------"
  end

  def self.create_bill(result, subscription, autofetched)
    if autofetched
      ## Create Autofectched bill from BillFetch Response
      return unless result.status == 'Y'
      bill_parse_op = Docs::UtilityBills::Bills::Ops::BillParser.(params: {data: result}, current_user: User.first)

      parsed_bill_data = bill_parse_op[:result].merge({autofetched: autofetched, subscription_id: subscription.id})

      op = Docs::UtilityBills::Bills::Ops::Create.(params: parsed_bill_data, current_user: User.first)
      if op.success?
        new_bill = op['model']
        Docs::UtilityBills::Bills::Mailers::New::Autofetched.(params: {record: new_bill}, current_user: User.first)
      end
    else
      ## Create Manual bill on behalf of user
      params = {
          amount: 0,
          bill_date: subscription.expected_bill_day,
          bill_period: Date.today.strftime("%B"),
          subscription_id: subscription.id,
          autofetched: autofetched
      }
      op = Docs::UtilityBills::Bills::Ops::Create.(params: params, current_user: User.first)
      if op.success?
        new_bill = op['model']
        Docs::UtilityBills::Bills::Mailers::New::Manual.(params: {record: new_bill}, current_user: User.first)
      end
    end
  end


  def self.customer_params(subscription)
    parameters = {mobile_number: subscription.mobile_number, biller_id: subscription.biller&.biller_id}

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
end
