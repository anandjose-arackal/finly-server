class Docs::P2P::CreditNotes::Mailers::Approve < Docs::P2P::CreditNotes::Mailers::Base

  # 'approved_by', 'approved_to', 'approved_for'

  class Docs::P2P::CreditNotes::Mailers::Approve::ApprovedBy < Docs::P2P::CreditNotes::Mailers::Approve

    consumes_event! 'credit_note.approve'

    assign :to do |user, params|
      [user.email]
    end

    assign :hero_bg_image, "bg_default"

    assign :subject do |user, params|
      "You have successfully approved the credit note #{params[:record].sequence_id}"
    end

    assign :title, "Credit Note Approved"

    assign :sub_header do |user, params|
      "You have successfully approved the credit note #{params[:record].sequence_id}"
    end
  end

  class Docs::P2P::CreditNotes::Mailers::Approve::ApprovedTo < Docs::P2P::CreditNotes::Mailers::Approve

    consumes_event! 'credit_note.approve'

    def validate(options, params:, **)
      return if params[:record].approved?
      true
    end

    assign :to do |user, params|
      [params[:record].get_reviewers.pluck(:email)]
    end

    assign :hero_bg_image, "bg_warning"

    assign :subject do |user, params|
      "#{user.name} has approved the credit note #{params[:record].sequence_id} and is awaiting your approval"
    end

    assign :title, "Credit Note Awaiting Your Approval"

    assign :sub_header do |user, params|
      "#{user.name} has approved the credit note #{params[:record].sequence_id} and is awaiting your approval"
    end
  end

  class Docs::P2P::CreditNotes::Mailers::Approve::ApprovedFor < Docs::P2P::CreditNotes::Mailers::Approve

    consumes_event! 'credit_note.approve'

    def validate(options, params:, **)
      return unless params[:record].approved?
      true
    end

    assign :to do |user, params|
      [params[:record].user&.email]
    end

    assign :hero_bg_image, "bg_success"

    assign :subject do |user, params|
      "#{user.name} has approved the creidt note #{params[:record].sequence_id}"
    end

    assign :title, "Credit Note Approved"

    assign :sub_header do |user, params|
      "#{user.name} has approved the credit note #{params[:record].sequence_id}"
    end
  end
end