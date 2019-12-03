module Documents::Invoices::Consumers::Submit
  module Processing
    class OwnerAction < TaskManager::Actions::DummyAction
      def run(user, message, input)
      end
    end

    class OwnerActions < TaskManager::API
      record Invoice
      consumes_event! 'invoice.submit', consumer_key: "Invoice.Submit.OwnerActions", name: "Report Submit Mailer"
      # scheduled! name: "Report Submit Schedule",every: 1.minute, hour: 12, minute: 00, day_of_the_week: :monday, day_of_the_month: :last
      validate_payload -> (user, message) do
        message[:record].present? #message[:invoice]&.status_id == InwardInvoiceStatus.id_for(:processing)}
      end
      validate_input -> (user, message, invoices) do
        true
      end
      pre_process -> (user, message, invoices) do
        true
      end
      action(
          TaskManager::Actions::DummyAction.define_action("UserSubmitOwnerMailer") do
            run -> (user, message, input) do
              # debugger
            end
          end
      )
      # action OwnerAction
      post_process -> (user, message, invoices) do
        true
      end
      # success -> (user, message, invoices) {true}
      # failed -> (user, message, invoices) {true}

      # action Documents::Invoices::Consumers::Mailers.define do |invoice|
      #   rule -> (invoice) {invoice.created_by.email.present?}
      #
      #   to invoice.created_by.email
      #   subject -> (invoice) {"Invoice submitted #{invoice.invoice_number}"}
      #   title 'Invoice Submitted'
      #   body -> {"You have successfully submitted invoice #{invoice.invoice_number}"}
      #
      #   list_headers ["Invoice ID", "Invoice Name"]
      #   list_items []
      #
      #   pre_process do |invoice|
      #
      #   end
      #
      #   post_process do |invoice|
      #
      #   end
      #
      #   when_bounced do |invoice|
      #
      #   end
      #
      #   when_sent do |invoice|
      #
      #   end
      #
      #   when_delivered do |invoice|
      #
      #   end
      #
      #   when_opened do |invoice|
      #
      #   end
      # end
    end
  end
end