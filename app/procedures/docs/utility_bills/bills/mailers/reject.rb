class Docs::UtilityBills::Bills::Mailers::Reject < Notifier::Mailer

  # 'rejected_by', 'rejected_to'

  class Docs::UtilityBills::Bills::Mailers::Reject::RejectedBy < Docs::UtilityBills::Bills::Mailers::Reject

    consumes_event! 'bbps_bill.reject'

    assign :to do |user, params|
      [user.email]
    end

    assign :subject do |user, params|
      "You have rejected the utility bill #{params[:record].sequence_id}"
    end

    assign :title do |user, params|
      "You have rejected the utility bill #{params[:record].sequence_id}"
    end
  end

  class Docs::UtilityBills::Bills::Mailers::Reject::RejectedTo < Docs::UtilityBills::Bills::Mailers::Reject

    consumes_event! 'bbps_bill.reject'

    assign :to do |user, params|
      [params[:document]&.user&.email]
    end

    assign :subject do |user, params|
      "#{user.name} has rejected the utility bill #{params[:record].sequence_id}"
    end

    assign :title do |user, params|
      "#{user.name} has rejected the utility bill #{params[:record].sequence_id}"
    end
  end
end