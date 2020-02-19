class Docs::UtilityBills::Bills::Mailers::Submit < Notifier::Mailer

  class Docs::UtilityBills::Bills::Mailers::Submit::SubmittedFrom < Docs::UtilityBills::Bills::Mailers::Submit

    consumes_event! 'bbps_bill.submit'

    assign :to do |user, params|
      [user.email]
    end

    assign :subject do |user, params|
      "You have successfully submitted utility bill #{params[:record].sequence_id}"
    end

    assign :title do |user, params|
      "You have successfully submitted utility bill #{params[:record].sequence_id}"
    end
  end

  class Docs::UtilityBills::Bills::Mailers::Submit::SubmittedTo < Docs::UtilityBills::Bills::Mailers::Submit

    consumes_event! 'bbps_bill.submit'

    assign :to do |user, params|
      [user.email]
    end

    assign :subject do |user, params|
      "#{user.name} has submitted utility bill #{params[:record].sequence_id} and is awaiting your approval"
    end

    assign :title do |user, params|
      "#{user.name} has submitted utility bill #{params[:record].sequence_id} and is awaiting your approval"
    end
  end
end