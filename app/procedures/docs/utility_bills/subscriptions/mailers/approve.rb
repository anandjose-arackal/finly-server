class Docs::UtilityBills::Subscriptions::Mailers::Approve < Docs::UtilityBills::Subscriptions::Mailers::Base

  class Docs::UtilityBills::Subscriptions::Mailers::Approve::ApprovedBy < Docs::UtilityBills::Subscriptions::Mailers::Approve

    consumes_event! 'bbps_biller_subscription.approve'

    assign :to do |user, params|
      [user.email]
    end

    assign :hero_bg_image, "bg_default"

    assign :subject do |user, params|
      "Approved Utility Bill Master #{params[:record].sequence_id}"
    end

    assign :title, "Utility Bill Master Approved"

    assign :sub_header do |user, params|
      "You have successfully approved utility bill master #{params[:record].sequence_id}"
    end
  end

  class Docs::UtilityBills::Subscriptions::Mailers::Approve::ApprovedTo < Docs::UtilityBills::Subscriptions::Mailers::Approve

    consumes_event! 'bbps_biller_subscription.approve'

    def validate(options, params:, **)
      return if params[:record].approved?
      true
    end

    assign :to do |user, params|
      params[:record].get_reviewers.pluck(:email)
    end

    assign :hero_bg_image, "bg_warning"

    assign :subject do |user, params|
      "#{user.name} has approved the utility bill master #{params[:record].sequence_id} and is awaiting your approval"
    end

    assign :title do |user, params|
      "Utility Bill Master Awaiting Your Approval"
    end

    assign :sub_header do |user, params|
      "#{user.name} has approved the utility bill master #{params[:record].sequence_id} and is awaiting your approval"
    end
  end

  class Docs::UtilityBills::Subscriptions::Mailers::Approve::ApprovedFor < Docs::UtilityBills::Subscriptions::Mailers::Approve

    consumes_event! 'bbps_biller_subscription.approve'

    def validate(options, params:, **)
      return unless params[:record].approved?
      true
    end

    assign :hero_bg_image, "bg_success"

    assign :to do |user, params|
      [params[:record].user&.email]
    end

    assign :subject do |user, params|
      "#{user.name} has approved the utility bill master #{params[:record].sequence_id}"
    end

    assign :title, "Utility Bill Master Approved"

    assign :title do |user, params|
      "#{user.name} has approved the utility bill master #{params[:record].sequence_id}"
    end
  end
end