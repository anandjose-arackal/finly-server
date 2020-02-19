class Docs::UtilityBills::Bills::Mailers::TakeControl

  # 'taken_control_by', 'taken_control_from'

  class Docs::UtilityBills::Bills::Mailers::TakeControl::TakenControlBy < Notifier::Mailer

    consumes_event! 'bbps_bill.take_control'

    assign :to do |user, params|
      [user.email]
    end

    assign :subject do |user, params|
      "You have taken control of the utility bill #{params[:record].sequence_id}"
    end

    assign :title do |user, params|
      "You have taken control of the utility bill #{params[:record].sequence_id}"
    end
  end

  class Docs::UtilityBills::Bills::Mailers::TakeControl::TakenControlFrom < Notifier::Mailer

    consumes_event! 'bbps_bill.take_control'

    assign :to do |user, params|
      record = params[:record]
      user_ids = record.document_level_reviewer_mappings.with_level_id(record.controlling_level_id).pluck(:reviewer_id)
      User.where(id: user_ids).pluck(:email)
    end

    assign :subject do |user, params|
      "#{user.name} has taken control of the utility bill #{params[:record].sequence_id}"
    end

    assign :title do |user, params|
      "#{user.name} has taken control of the utility bill #{params[:record].sequence_id}"
    end
  end
end