class Docs::P2P::CreditNotes::Mailers::Submit < Notifier::Mailer

  class Docs::P2P::CreditNotes::Mailers::Submit::SubmittedFrom < Docs::P2P::CreditNotes::Mailers::Submit

    consumes_event! 'credit_note.submit'

    assign :to do |user, params|
      [user.email]
    end

    assign :subject do |user, params|
      "You have successfully submitted credit note #{params[:record].sequence_id}"
    end

    assign :title do |user, params|
      "You have successfully submitted credit note #{params[:record].sequence_id}"
    end
  end

  class Docs::P2P::CreditNotes::Mailers::Submit::SubmittedTo < Docs::P2P::CreditNotes::Mailers::Submit

    consumes_event! 'credit_note.submit'

    assign :to do |user, params|
      [user.email]
    end

    assign :subject do |user, params|
      "#{user.name} has submitted credit note #{params[:record].sequence_id} and is awaiting your approval"
    end

    assign :title do |user, params|
      "#{user.name} has submitted credit note #{params[:record].sequence_id} and is awaiting your approval"
    end
  end
end