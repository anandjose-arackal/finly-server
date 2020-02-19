class Docs::UtilityBills::Bills::Mailers::Submit < Docs::UtilityBills::Bills::Mailers::Base

  class Docs::UtilityBills::Bills::Mailers::Submit::SubmittedFrom < Docs::UtilityBills::Bills::Mailers::Submit

    consumes_event! 'bbps_bill.submit'

    assign :to do |user, params|
      [user.email]
    end

    assign :hero_bg_image, "bg_default"

    assign :subject do |user, params|
      "You have successfully submitted utility bill #{params[:record].sequence_id}"
    end

    assign :title, "Utility Bill Submitted"

    assign :sub_header do |user, params|
      "You have successfully submitted utility bill #{params[:record].sequence_id}"
    end
  end

  class Docs::UtilityBills::Bills::Mailers::Submit::SubmittedTo < Docs::UtilityBills::Bills::Mailers::Submit

    consumes_event! 'bbps_bill.submit'

    assign :to do |user, params|
      params[:record].get_reviewers.pluck(:email)
    end

    assign :hero_bg_image, "bg_warning"

    assign :subject do |user, params|
      "#{user.name} has submitted utility bill #{params[:record].sequence_id} and is awaiting your approval"
    end

    assign :title, "Utility Bill Awaiting Your Approval"

    assign :sub_header do |user, params|
      "#{user.name} has submitted the utility bill #{params[:record].sequence_id} and is awaiting your approval"
    end
  end
end