class Docs::UtilityBills::Subscriptions::Mailers::TakeControl < Docs::UtilityBills::Subscriptions::Mailers::Base

  class Docs::UtilityBills::Subscriptions::Mailers::TakeControl::TakenControlBy < Docs::UtilityBills::Subscriptions::Mailers::TakeControl

    consumes_event! 'bbps_biller_subscription.take_control'

    assign :to do |user, params|
      [user.email]
    end

    assign :hero_bg_image, "bg_default"

    assign :subject do |user, params|
      "You have taken control of the utility bill master #{params[:record].sequence_id}"
    end

    assign :title, "Utility Bill Master Taken Control"

    assign :sub_header do |user, params|
      "You have taken control of the utility bill master #{params[:record].sequence_id}"
    end
  end

  class Docs::UtilityBills::Subscriptions::Mailers::TakeControl::TakenControlFrom < Docs::UtilityBills::Subscriptions::Mailers::TakeControl

    consumes_event! 'bbps_biller_subscription.take_control'

    assign :to do |user, params|
      record = params[:record]
      user_ids = record.document_level_reviewer_mappings.with_level_id(record.controlling_level_id).pluck(:reviewer_id)
      User.where(id: user_ids).pluck(:email)
    end

    assign :hero_bg_image, "bg_default"

    assign :subject do |user, params|
      "#{user.name} has taken control of the utility bill master #{params[:record].sequence_id}"
    end

    assign :title, "Utility Bill Master Taken Control"

    assign :sub_header do |user, params|
      "#{user.name} has taken control of the utility bill master #{params[:record].sequence_id}"
    end
  end
end