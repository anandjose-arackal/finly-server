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


    bbps_subscriptions = BbpsBillerSubscription.where(status_id: status_ids, auto_generate_bill: true).where.not(expected_bill_day: nil)

    bbps_subscriptions.each do |subscription|
      # Day of month for today
      today_day = Date.today.day

      # Last day of month
      last_day_of_month = Date.today.end_of_month.day

      # Day of month 2 days before subscription's expected bill day
      subscription_bill_day = subscription.expected_bill_day.to_i - 2

      subscription_bill_day = last_day_of_month + subscription_bill_day if [-1, 0].include?(subscription_bill_day)
      # subscription_bill_day = last_day_of_month + subscription_bill_day if [-1, 0].include?(subscription_bill_day)

      autofetched = false
      if today_day == subscription_bill_day
        create_bill(result, subscription, autofetched)
      end
    end
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
