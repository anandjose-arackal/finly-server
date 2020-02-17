class Docs::UtilityBills::Subscriptions::Mailers::Approve

  # 'approved_by', 'approved_to', 'approved_for'

  class Docs::UtilityBills::Subscriptions::Mailers::Approve::ApprovedBy < Notifier::Mailer

    consumes_event! 'bbps_biller_subscription.approve.approved_by', consumer_key: self.name, name: self.name

    assign :to do |user, params|
      [user.email]
    end

    assign :subject do |user, params|
      "You have successfully approved utility bill master #{params[:record].sequence_id}"
    end

    assign :title do |user, params|
      "You have successfully approved utility bill master #{params[:record].sequence_id}"
    end
  end

  class Docs::UtilityBills::Subscriptions::Mailers::Approve::ApprovedTo < Notifier::Mailer

    consumes_event! 'bbps_biller_subscription.approve.approved_to', consumer_key: self.name, name: self.name

    def validate(options, document:, **)
      return if document.approved?
      true
    end

    assign :to do |user, params|
      [params[:document].get_reviewers.pluck(:email)]
    end

    assign :subject do |user, params|
      "#{user.name} has approved the utility bill master #{params[:record].sequence_id} and is awaiting your approval"
    end

    assign :title do |user, params|
      "#{user.name} has approved the utility bill master #{params[:record].sequence_id} and is awaiting your approval"
    end
  end

  class Docs::UtilityBills::Subscriptions::Mailers::Approve::ApprovedFor < Notifier::Mailer

    consumes_event! 'bbps_biller_subscription.approve.approved_for', consumer_key: self.name, name: self.name

    def validate(options, document:, **)
      return unless document.approved?
      true
    end

    assign :to do |user, params|
      [params[:document].user&.email]
    end

    assign :subject do |user, params|
      "#{user.name} has approved the utility bill master #{params[:record].sequence_id}"
    end

    assign :title do |user, params|
      "#{user.name} has approved the utility bill master #{params[:record].sequence_id}"
    end
  end
end