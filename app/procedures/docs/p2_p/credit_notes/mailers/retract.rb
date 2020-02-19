class Docs::P2P::CreditNotes::Mailers::Retract < Notifier::Mailer

  # 'rejected_by', 'rejected_to'

  class Docs::P2P::CreditNotes::Mailers::Retract::RetractedBy < Docs::P2P::CreditNotes::Mailers::Retract

    consumes_event! 'credit_note.retract'

    assign :to do |user, params|
      [user.email]
    end

    assign :subject do |user, params|
      "You have retracted the credi ntoe #{params[:record].sequence_id}"
    end

    assign :title do |user, params|
      "You have retracted the credi ntoe #{params[:record].sequence_id}"
    end
  end

  class Docs::P2P::CreditNotes::Mailers::Retract::RetractedFrom < Docs::P2P::CreditNotes::Mailers::Retract

    consumes_event! 'credit_note.retract'

    assign :to do |user, params|
      record = params[:record]
      last_retract_trail = record.trails.reload.with_action_id(TrailAction.id_for(:retract)).last
      user_ids = record.get_reviewers(last_retract_trail&.action_level_id)&.map(&:id)
      User.where(id: user_ids).pluck(:email)
    end

    assign :subject do |user, params|
      "#{user.name} has retracted the credi ntoe #{params[:record].sequence_id}"
    end

    assign :title do |user, params|
      "#{user.name} has retracted the credi ntoe #{params[:record].sequence_id}"
    end
  end
end