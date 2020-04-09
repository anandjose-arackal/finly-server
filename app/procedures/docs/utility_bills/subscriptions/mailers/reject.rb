class Docs::UtilityBills::Subscriptions::Mailers::Reject < Docs::UtilityBills::Subscriptions::Mailers::Base

  class Docs::UtilityBills::Subscriptions::Mailers::Reject::RejectedBy < Docs::UtilityBills::Subscriptions::Mailers::Reject

    consumes_event! 'bbps_biller_subscription.reject'

    assign :to do |user, params|
      [user.email]
    end

    assign :hero_bg_image, "bg_default"

    assign :subject do |user, params|
      "You have rejected the utility bill master #{params[:record].sequence_id}"
    end

    assign :title, "Utility Bill Master Rejected"

    assign :sub_header do |user, params|
      "You have rejected the utility bill master #{params[:record].sequence_id}"
    end
  end

  class Docs::UtilityBills::Subscriptions::Mailers::Reject::RejectedTo < Docs::UtilityBills::Subscriptions::Mailers::Reject

    consumes_event! 'bbps_biller_subscription.reject'

    assign :to do |user, params|
      [params[:record]&.user&.email]
    end

    assign :body_quote_text do |user, params|
      params[:record].reload.review_note
    end

    assign :body_quote_by do |user, params|
      user.name
    end

    assign :hero_bg_image, "bg_danger"

    assign :subject do |user, params|
      "#{user.name} has rejected the utility bill master #{params[:record].sequence_id}"
    end

    assign :title, "Utility Bill Master Rejected"

    assign :sub_header do |user, params|
      "#{user.name} has rejected the utility bill master #{params[:record].sequence_id}"
    end
  end
end