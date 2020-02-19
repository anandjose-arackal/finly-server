class Docs::P2P::CreditNotes::Mailers::Reject < Notifier::Mailer

  # 'rejected_by', 'rejected_to'

  class Docs::P2P::CreditNotes::Mailers::Reject::RejectedBy < Docs::P2P::CreditNotes::Mailers::Reject

    consumes_event! 'credit_note.reject'

    assign :to do |user, params|
      [user.email]
    end

    assign :subject do |user, params|
      "You have rejected the credit note #{params[:record].sequence_id}"
    end

    assign :title do |user, params|
      "You have rejected the credit note #{params[:record].sequence_id}"
    end
  end

  class Docs::P2P::CreditNotes::Mailers::Reject::RejectedTo < Docs::P2P::CreditNotes::Mailers::Reject

    consumes_event! 'credit_note.reject'

    assign :to do |user, params|
      [params[:document]&.user&.email]
    end

    assign :subject do |user, params|
      "#{user.name} has rejected the credit note #{params[:record].sequence_id}"
    end

    assign :title do |user, params|
      "#{user.name} has rejected the credit note #{params[:record].sequence_id}"
    end
  end
end