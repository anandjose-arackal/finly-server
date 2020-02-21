class Docs::P2P::CreditNotes::Mailers::Reject < Docs::P2P::CreditNotes::Mailers::Base

  class Docs::P2P::CreditNotes::Mailers::Reject::RejectedBy < Docs::P2P::CreditNotes::Mailers::Reject

    consumes_event! 'credit_note.reject'

    assign :to do |user, params|
      [user.email]
    end

    assign :hero_bg_image, "bg_default"

    assign :subject do |user, params|
      "You have rejected the credit note #{params[:record].sequence_id}"
    end

    assign :title, "Credit Note Rejected"

    assign :sub_header do |user, params|
      "You have rejected the credit note #{params[:record].sequence_id}"
    end
  end

  class Docs::P2P::CreditNotes::Mailers::Reject::RejectedTo < Docs::P2P::CreditNotes::Mailers::Reject

    consumes_event! 'credit_note.reject'

    assign :to do |user, params|
      [params[:record]&.user&.email]
    end

    assign :body_quote_text do |user, params|
      params[:record].review_note
    end

    assign :body_quote_by do |user, params|
      user.name
    end

    assign :hero_bg_image, "bg_danger"

    assign :subject do |user, params|
      "#{user.name} has rejected the credit note #{params[:record].sequence_id}"
    end

    assign :title, "Credit Note Rejected"

    assign :sub_header do |user, params|
      "#{user.name} has rejected the credit note #{params[:record].sequence_id}"
    end
  end
end