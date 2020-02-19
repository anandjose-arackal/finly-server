class Docs::UtilityBills::Subscriptions::Mailers::Submit < Docs::UtilityBills::Subscriptions::Mailers::Base


  class Docs::UtilityBills::Subscriptions::Mailers::Submit::SubmittedFrom < Docs::UtilityBills::Subscriptions::Mailers::Submit

    consumes_event! 'bbps_biller_subscription.submit'

    assign :to do |user, params|
      [user.email]
    end

    assign :hero_bg_image, "bg_default"

    assign :subject do |user, params|
      "You have successfully submitted utility bill master #{params[:record].sequence_id}"
    end

    assign :title, "Utility Bill Master Submitted for Approval"

    assign :sub_header do |user, params|
      "You have successfully submitted utility bill master #{params[:record].sequence_id}"
    end

  end

  class Docs::UtilityBills::Subscriptions::Mailers::Submit::SubmittedTo < Docs::UtilityBills::Subscriptions::Mailers::Submit

    consumes_event! 'bbps_biller_subscription.submit'

    assign :to do |user, params|
      params[:record].get_reviewers.pluck(:email)
    end

    assign :hero_bg_image, "bg_warning"

    assign :subject do |user, params|
      "#{user.name} has submitted utility bill master #{params[:record].sequence_id} and is awaiting your approval"
    end

    assign :title, "Utility Bill Master Awaiting Your Approval"

    assign :sub_header do |user, params|
      "#{user.name} has submitted utility bill master #{params[:record].sequence_id} and is awaiting your approval"
    end
  end
end