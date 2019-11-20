class BbpsBillsFetch < ApplicationJob

  def perform
    # Fetch bills where automatic fetching is enabled
    status_ids = [BbpsBillerSubscription.status_ids(:approved, :auto_approved, :reactivated)]
    bbps_subscriptions = BbpsBillerSubscription.where(status_id: status_ids, auto_generate_bill: true).where(expected_bill_day: nil)
    autofetched = true
    bbps_subscriptions.each do |subscription|
      Bbps::BillFetch.(parameters, "current_user" => User.first) do |op|
        op.success {|result| create_bill(result, subscription, autofetched)}
        op.error {|result| log_error(result, subscription)}
      end
    end

    # Where Auto Fetching Bills not supported by vendors
    # Create bills two days before expected bill day
    autofetched = false
    bill_day = (Date.today + 2.days).day
    bbps_subscriptions = BbpsBillerSubscription.where(status_id: status_ids, auto_generate_bill: true).where.not(expected_bill_day: bill_day)
    bbps_subscriptions.each {|subscription| create_bill({}, subscription, autofetched)}
  end

  def create_bill(result, subscription, autofetched)
    if autofetched
      params = {
          amount: result.amount,
          bill_date: result.bill_date,
          bill_number: result.bill_number,
          due_date: result.due_date,
          bill_period: result.bill_period,
          convenience_fee: result.convenience_fee,
          convenience_fee_desc: result.convenience_fee_desc,
          early_payment_fee: result.early_payment_fee,
          late_payment_fee: result.late_payment_fee,
          subscription_id: subscription.id,
          autofetched: autofetched
      }

      op = Docs::UtilityBills::Bills::Ops::Create.(params)
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
    end
    op = Docs::UtilityBills::Bills::Ops::Create.(params)
  end


end
