class Docs::UtilityBills::Subscriptions::Mailers::Reject

  # 'rejected_by', 'rejected_to'

  class Docs::UtilityBills::Subscriptions::Mailers::Reject::RejectedBy < Notifier::Mailer

    consumes_event! 'bbps_biller_subscription.reject.rejected_by', consumer_key: self.name, name: self.name

    assign :to do |user, params|
      [user.email]
    end

    assign :subject do |user, params|
      "You have rejected the utility bill master #{params[:record].sequence_id}"
    end

    assign :title do |user, params|
      "You have rejected the utility bill master #{params[:record].sequence_id}"
    end
  end

  class Docs::UtilityBills::Subscriptions::Mailers::Reject::RejectedTo < Notifier::Mailer

    consumes_event! 'bbps_biller_subscription.reject.rejected_to', consumer_key: self.name, name: self.name

    assign :to do |user, params|
      [params[:document]&.user&.email]
    end

    assign :subject do |user, params|
      "#{user.name} has rejected the utility bill master #{params[:record].sequence_id}"
    end

    assign :title do |user, params|
      "#{user.name} has rejected the utility bill master #{params[:record].sequence_id}"
    end
  end
end