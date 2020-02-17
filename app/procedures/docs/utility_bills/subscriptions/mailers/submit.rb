class Docs::UtilityBills::Subscriptions::Mailers::Submit

  # consumes_event! 'bbps_biller_subscription.submit', consumer_key: 'Docs::UtilityBills::Subscriptions::Mailers::Submitted', name: 'Docs::UtilityBills::Subscriptions::Mailers::Submitted'

  class Docs::UtilityBills::Subscriptions::Mailers::Submit::SubmittedFrom < Notifier::Mailer

    consumes_event! 'bbps_biller_subscription.submit.submitted_from', consumer_key: self.name, name: self.name

    assign :to do |user, params|
      [user.email]
    end

    assign :subject do |user, params|
      "You have successfully submitted utility bill master #{params[:record].sequence_id}"
    end

    assign :title do |user, params|
      "You have successfully submitted utility bill master #{params[:record].sequence_id}"
    end
  end

  class Docs::UtilityBills::Subscriptions::Mailers::Submit::SubmittedTo < Notifier::Mailer

    consumes_event! 'bbps_biller_subscription.submit.submitted_to', consumer_key: self.name, name: self.name

    assign :to do |user, params|
      [user.email]
    end

    assign :subject do |user, params|
      "#{user.name} has submitted utility bill master #{params[:record].sequence_id} and is awaiting your approval"
    end

    assign :title do |user, params|
      "#{user.name} has submitted utility bill master #{params[:record].sequence_id} and is awaiting your approval"
    end
  end
end