class Docs::UtilityBills::Subscriptions::Mailers::ReturnControl < Docs::UtilityBills::Subscriptions::Mailers::Base

  class Docs::UtilityBills::Subscriptions::Mailers::ReturnControl::ReturnedControlBy < Docs::UtilityBills::Subscriptions::Mailers::ReturnControl

    consumes_event! 'bbps_biller_subscription.return_control'

    assign :to do |user, params|
      [user.email]
    end

    assign :hero_bg_image, "bg_default"

    assign :subject do |user, params|
      "You have returned control of the utility bill master #{params[:record].sequence_id}"
    end

    assign :title do |user, params|
      "Utility Bill Master Control Returned"
    end

    assign :sub_header do |user, params|
      "You have returned control of the utility bill master #{params[:record].sequence_id}"
    end
  end

  class Docs::UtilityBills::Subscriptions::Mailers::ReturnControl::ReturnedControlTo < Docs::UtilityBills::Subscriptions::Mailers::ReturnControl

    consumes_event! 'bbps_biller_subscription.return_control'

    assign :to do |user, params|
      record = params[:record]
      user_ids = record.document_level_reviewer_mappings.with_level_id(record.controlling_level_id).pluck(:reviewer_id)
      User.where(id: user_ids).pluck(:email)
    end

    assign :hero_bg_image, "bg_warning"

    assign :subject do |user, params|
      "#{user.name} has taken control of the utility bill master #{params[:record].sequence_id}"
    end

    assign :title, "Utility Bill Master Control Returned"

    assign :sub_header do |user, params|
      "#{user.name} has returned control of the utility bill master #{params[:record].sequence_id} & is awaiting your approval"
    end
  end
end