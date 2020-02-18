class Docs::UtilityBills::Bills::Mailers::PaymentReminder < Notifier::Mailer

  # 'autofetched', 'manual'

  class Docs::UtilityBills::Bills::Mailers::PaymentReminder::Autofetched < Docs::UtilityBills::Bills::Mailers::PaymentReminder

    consumes_event! 'bbps_bill.remind_payment.autofetched', consumer_key: self.name, name: self.name

    assign :to do |user, params|
      bill = params[:record]
      bill.subscription.pocs.pluck(:email)
    end

    assign :subject do |user, params|
      subscription = params[:record]&.subscription
      "New Utility Bill Available for #{subscription.name} - #{subscription.sequence_id}"
    end

    assign :title do |user, params|
      subscription = params[:record]&.subscription
      "New Utility Bill Available"
    end

    assign :sub_header do |user, params|
      subscription = params[:record]&.subscription
      "A New Utility Bill is Available for #{subscription.name} - #{subscription.sequence_id}"
    end

    assign :tables do |user, params|
      bill = params[:record]
      tables = []

      table = {
          content: {
              tbody: [
                  ["Biller", bill.biller.name],
                  ["Name", bill.subscription.name],
                  ["Amount", "#{bill.amount.currency.country_code} #{bill.amount.value}"],
                  ["Bill Date", bill.bill_date],
                  ["Due Date", bill.due_date],
                  ["Type", "Autofetched"]
              ]
          }
      }

      tables.push(table)
    end
  end
end