class BbpsBillsFetch < ApplicationJob

  def perform
    status_ids = [BbpsBillerSubscription.status_ids(:approved, :auto_approved, :reactivated)]

    bbps_subscriptions = BbpsBillerSubscription.where(status_id: status_ids, auto_generate_bill: true)

    bbps_subscriptions.each do |subscription|

      Bbps::BillFetch.(parameters, "current_user" => User.first) do |op|
        op.success {|result| create_bill(result, subscription)}
        op.error {|result| log_error(result, subscription)}
      end
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

  def create_bill(result, subscription)
    params = {
        amount: 500,
        bill_date: result.bill_date,
        bill_number: result.bill_number,
        due_date: result.due_date,
        bill_period: result.bill_period,
        convenience_fee: result.convenience_fee,
        convenience_fee_desc: result.convenience_fee_desc,
        early_payment_fee: result.early_payment_fee,
        late_payment_fee: result.late_payment_fee,

        subscription_id: subscription.id,
        autofetched: true,
    }

    op = Docs::UtilityBills::Bills::Ops::Create.(params)

    unless op.success?

    end
  end


end
