class Docs::UtilityBills::Subscriptions::Mailers::Retract < Notifier::Mailer

  # 'rejected_by', 'rejected_to'

  class Docs::UtilityBills::Subscriptions::Mailers::Retract::RetractedBy < Docs::UtilityBills::Subscriptions::Mailers::Retract

    consumes_event! 'bbps_biller_subscription.retract.retracted_by', consumer_key: self.name, name: self.name

    assign :to do |user, params|
      [user.email]
    end

    assign :subject do |user, params|
      "You have retracted the utility bill master #{params[:record].sequence_id}"
    end

    assign :title do |user, params|
      "You have retracted the utility bill master #{params[:record].sequence_id}"
    end
  end

  class Docs::UtilityBills::Subscriptions::Mailers::Retract::RetractedFrom < Docs::UtilityBills::Subscriptions::Mailers::Retract

    consumes_event! 'bbps_biller_subscription.retract.retracted_from', consumer_key: self.name, name: self.name

    assign :to do |user, params|
      record = params[:record]
      last_retract_trail = record.trails.reload.with_action_id(TrailAction.id_for(:retract)).last
      user_ids = record.get_reviewers(last_retract_trail&.action_level_id)&.map(&:id)
      User.where(id: user_ids).pluck(:email)
    end

    assign :subject do |user, params|
      "#{user.name} has retracted the utility bill master #{params[:record].sequence_id}"
    end

    assign :title do |user, params|
      "#{user.name} has retracted the utility bill master #{params[:record].sequence_id}"
    end
  end
end