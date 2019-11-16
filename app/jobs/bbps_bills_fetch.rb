class BbpsBillsFetch < ApplicationJob

  def perform
    status_ids = [BbpsBillerSubscription.status_ids(:approved, :auto_approved, :reactivated)]

    bbps_subscriptions = BbpsBillerSubscription.where(status_id: status_ids, auto_generate_bill: true)

    bbps_subscriptions.each do |subscription|
      # Operation 1 : Query Bbps API for fetching new bills
      # todo
      parameters = set_parameters(subscription)


      bill_fetch_operation = Bbps::BillFetch.(parameters)


      # Operation 2 : Generate Bill
      params = {
          subscription_id: subscription.id,

          amount: (rand * 1000).round(2), #todo Add amount from Operation #1
          due_date: Date.today, #todo Add date from Operation #1
      }

      op = Docs::UtilityBills::Bills::Ops::Create.(params)
    end

  end

  def customer_params(subscription)

    parameters = {
        mobile_number: subscription.mobile_number,
        biller_id: subscription.biller_id,
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


end
