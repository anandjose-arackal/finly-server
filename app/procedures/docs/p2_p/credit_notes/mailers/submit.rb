class Docs::P2P::CreditNotes::Mailers::Submit < Docs::P2P::CreditNotes::Mailers::Base

  class Docs::P2P::CreditNotes::Mailers::Submit::SubmittedFrom < Docs::P2P::CreditNotes::Mailers::Submit

    consumes_event! 'credit_notes.submit'

    assign :to do |user, params|
      [user.email]
    end

    assign :hero_bg_image, "bg_default"

    assign :subject do |user, params|
      "You have successfully submitted credit note #{params[:record].sequence_id}"
    end

    assign :title, "Credit Note Submitted"

    assign :sub_header do |user, params|
      "You have successfully submitted credit note #{params[:record].sequence_id}"
    end
  end

  class Docs::P2P::CreditNotes::Mailers::Submit::SubmittedTo < Docs::P2P::CreditNotes::Mailers::Submit

    consumes_event! 'credit_notes.submit'

    assign :to do |user, params|
      params[:record].get_reviewers.pluck(:email)
    end

    assign :hero_bg_image, "bg_warning"

    assign :subject do |user, params|
      "#{user.name} has submitted credit note #{params[:record].sequence_id} and is awaiting your approval"
    end

    assign :title, "Credit Note Awaiting Your Approval"

    assign :sub_header do |user, params|
      "#{user.name} has submitted credit note #{params[:record].sequence_id} and is awaiting your approval"
    end
  end
end