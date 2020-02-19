class Docs::UtilityBills::Bills::Mailers::Approve < Notifier::Mailer

  # 'approved_by', 'approved_to', 'approved_for'

  class Docs::UtilityBills::Bills::Mailers::Approve::ApprovedBy < Docs::UtilityBills::Bills::Mailers::Approve

    consumes_event! 'bbps_bill.approve'

    assign :to do |user, params|
      [user.email]
    end

    assign :subject do |user, params|
      "You have successfully approved utility bill #{params[:record].sequence_id}"
    end

    assign :title do |user, params|
      "You have successfully approved utility bill #{params[:record].sequence_id}"
    end
  end

  class Docs::UtilityBills::Bills::Mailers::Approve::ApprovedTo < Docs::UtilityBills::Bills::Mailers::Approve

    consumes_event! 'bbps_bill.approve'

    def validate(options, document:, **)
      return if document.approved?
      true
    end

    assign :to do |user, params|
      [params[:document].get_reviewers.pluck(:email)]
    end

    assign :subject do |user, params|
      "#{user.name} has approved the utility bill #{params[:record].sequence_id} and is awaiting your approval"
    end

    assign :title do |user, params|
      "#{user.name} has approved the utility bill #{params[:record].sequence_id} and is awaiting your approval"
    end
  end

  class Docs::UtilityBills::Bills::Mailers::Approve::ApprovedFor < Docs::UtilityBills::Bills::Mailers::Approve

    consumes_event! 'bbps_bill.approve'

    def validate(options, document:, **)
      return unless document.approved?
      true
    end

    assign :to do |user, params|
      [params[:document].user&.email]
    end

    assign :subject do |user, params|
      "#{user.name} has approved the utility bill #{params[:record].sequence_id}"
    end

    assign :title do |user, params|
      "#{user.name} has approved the utility bill #{params[:record].sequence_id}"
    end
  end
end