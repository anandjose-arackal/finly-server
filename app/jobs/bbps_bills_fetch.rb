class BbpsBillsFetch < ApplicationJob

  def perform
    status_ids = [BbpsBillerSubscription.status_ids(:approved, :auto_approved, :reactivated)]

    bbps_subscriptions = BbpsBillerSubscription.where(status_id: status_ids)

    bbps_subscriptions.each do |subscription|
      # Operation 1 : Query Bbps API for fetching new bills
      # todo

      # Operation 2 : Generate Bill
      params = {
          subscription_id: subscription.id,
          amount: (rand * 1000).round(2), #todo Add amount from Operation #1
          due_date: Date.today, #todo Add date from Operation #1
      }

      op = Docs::UtilityBills::Bills::Ops::Create.(params)
    end

  end
end
