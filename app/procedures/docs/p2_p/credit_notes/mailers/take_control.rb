class Docs::P2P::CreditNotes::Mailers::TakeControl < Notifier::Mailer

  # 'taken_control_by', 'taken_control_from'

  class Docs::P2P::CreditNotes::Mailers::TakeControl::TakenControlBy < Docs::P2P::CreditNotes::Mailers::TakeControl

    consumes_event! 'credit_note.take_control.taken_control_by', consumer_key: self.name, name: self.name

    assign :to do |user, params|
      [user.email]
    end

    assign :subject do |user, params|
      "You have taken control of the credit note #{params[:record].sequence_id}"
    end

    assign :title do |user, params|
      "You have taken control of the credit note #{params[:record].sequence_id}"
    end
  end

  class Docs::P2P::CreditNotes::Mailers::TakeControl::TakenControlFrom < Docs::P2P::CreditNotes::Mailers::TakeControl

    consumes_event! 'credit_note.take_control.taken_control_from', consumer_key: self.name, name: self.name

    assign :to do |user, params|
      record = params[:record]
      user_ids = record.document_level_reviewer_mappings.with_level_id(record.controlling_level_id).pluck(:reviewer_id)
      User.where(id: user_ids).pluck(:email)
    end

    assign :subject do |user, params|
      "#{user.name} has taken control of the credit note #{params[:record].sequence_id}"
    end

    assign :title do |user, params|
      "#{user.name} has taken control of the credit note #{params[:record].sequence_id}"
    end
  end
end