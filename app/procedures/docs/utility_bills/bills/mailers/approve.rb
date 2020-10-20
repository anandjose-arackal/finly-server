class Docs::UtilityBills::Bills::Mailers::Approve < Docs::UtilityBills::Bills::Mailers::Base

  class Docs::UtilityBills::Bills::Mailers::Approve::ApprovedBy < Docs::UtilityBills::Bills::Mailers::Approve

    consumes_event! 'bbps_bills.approve'

    assign :to do |user, params|
      [user.email]
    end

    assign :hero_bg_image, "bg_default"

    assign :subject do |user, params|
      "You have successfully approved utility bill #{params[:record].sequence_id}"
    end

    assign :title, "Utility Bill Approved"

    assign :sub_header do |user, params|
      "You have successfully approved utility bill #{params[:record].sequence_id}"
    end
  end

  class Docs::UtilityBills::Bills::Mailers::Approve::ApprovedTo < Docs::UtilityBills::Bills::Mailers::Approve

    consumes_event! 'bbps_bills.approve'

    def validate(options, params:, **)
      return if params[:record].approved?
      true
    end

    assign :hero_bg_image, "bg_warning"

    assign :to do |user, params|
      params[:record].get_reviewers.pluck(:email)
    end

    assign :subject do |user, params|
      "#{user.name} has approved the utility bill #{params[:record].sequence_id} and is awaiting your approval"
    end

    assign :title, "Utility Bill Awaiting Your Approval"

    assign :sub_header do |user, params|
      "#{user.name} has approved the utility bill #{params[:record].sequence_id} and is awaiting your approval"
    end
  end

  class Docs::UtilityBills::Bills::Mailers::Approve::ApprovedFor < Docs::UtilityBills::Bills::Mailers::Approve

    consumes_event! 'bbps_bills.approve'

    def validate(options, params:, **)
      return unless params[:record].approved?
      true
    end

    assign :to do |user, params|
      [params[:record].user&.email]
    end

    assign :hero_bg_image, "bg_success"

    assign :subject do |user, params|
      "#{user.name} has approved the utility bill #{params[:record].sequence_id}"
    end

    assign :title, "Utility Bill Approved"

    assign :sub_header do |user, params|
      "#{user.name} has approved the utility bill #{params[:record].sequence_id}"
    end
  end
end