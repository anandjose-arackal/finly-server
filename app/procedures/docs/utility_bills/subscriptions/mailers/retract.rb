class Docs::UtilityBills::Subscriptions::Mailers::Retract < Docs::UtilityBills::Subscriptions::Mailers::Base


  class Docs::UtilityBills::Subscriptions::Mailers::Retract::RetractedBy < Docs::UtilityBills::Subscriptions::Mailers::Retract

    consumes_event! 'bbps_biller_subscription.retract'

    assign :to do |user, params|
      [user.email]
    end

    assign :hero_bg_image, "bg_default"

    assign :subject do |user, params|
      "You have retracted the utility bill master #{params[:record].sequence_id}"
    end

    assign :title, "Utility Bill Master Retracted"

    assign :sub_header do |user, params|
      "You have retracted the utility bill master #{params[:record].sequence_id}"
    end
  end

  class Docs::UtilityBills::Subscriptions::Mailers::Retract::RetractedFrom < Docs::UtilityBills::Subscriptions::Mailers::Retract

    consumes_event! 'bbps_biller_subscription.retract'

    assign :to do |user, params|
      record = params[:record]
      last_retract_trail = record.trails.reload.with_action_id(TrailAction.id_for(:retract)).last
      user_ids = record.get_reviewers(last_retract_trail&.action_level_id)&.map(&:id)
      User.where(id: user_ids).pluck(:email)
    end

    assign :hero_bg_image, "bg_default"

    assign :subject do |user, params|
      "#{user.name} has retracted the utility bill master #{params[:record].sequence_id}"
    end

    assign :title, "Utility Bill Master Retracted"

    assign :sub_header do |user, params|
      "#{user.name} has retracted the utility bill master #{params[:record].sequence_id}"
    end
  end
end