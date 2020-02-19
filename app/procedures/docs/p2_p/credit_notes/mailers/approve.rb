class Docs::P2P::CreditNotes::Mailers::Approve < Notifier::Mailer

  # 'approved_by', 'approved_to', 'approved_for'

  class Docs::P2P::CreditNotes::Mailers::Approve::ApprovedBy < Notifier::Mailer

    consumes_event! 'credit_note.approve'

    assign :to do |user, params|
      [user.email]
    end

    assign :subject do |user, params|
      "You have successfully approved the credit note #{params[:record].sequence_id}"
    end

    assign :title do |user, params|
      "You have successfully approved the credit note #{params[:record].sequence_id}"
    end
  end

  class Docs::P2P::CreditNotes::Mailers::Approve::ApprovedTo < Docs::P2P::CreditNotes::Mailers::Approve

    consumes_event! 'credit_note.approve'

    def validate(options, document:, **)
      return if document.approved?
      true
    end

    assign :to do |user, params|
      [params[:record].get_reviewers.pluck(:email)]
    end

    assign :subject do |user, params|
      "#{user.name} has approved the credit note #{params[:record].sequence_id} and is awaiting your approval"
    end

    assign :title do |user, params|
      "#{user.name} has approved the credit note #{params[:record].sequence_id} and is awaiting your approval"
    end
  end

  class Docs::P2P::CreditNotes::Mailers::Approve::ApprovedFor < Docs::P2P::CreditNotes::Mailers::Approve

    consumes_event! 'credit_note.approve'

    def validate(options, document:, **)
      return unless document.approved?
      true
    end

    assign :to do |user, params|
      [params[:document].user&.email]
    end

    assign :subject do |user, params|
      "#{user.name} has approved the creidt note #{params[:record].sequence_id}"
    end

    assign :title do |user, params|
      "#{user.name} has approved the credit note #{params[:record].sequence_id}"
    end
  end
end