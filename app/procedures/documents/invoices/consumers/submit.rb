module Documents::Invoices::Consumers::Submit
  module Processing
    class OwnerAction < TaskManager::Actions::DummyAction
      def run(user, message, input)
      end
    end

    class OwnerActions < TaskManager::Workflows::API
      consumes_event! 'invoice.submit'
      validate_payload -> (user, message) {message[:record].present?}#message[:invoice]&.status_id == InwardInvoiceStatus.id_for(:processing)}
      # validate_input -> (user, message, invoices){}
      # action TaskManager::Actions::DummyAction.define_action "UserSubmitOwnerMailer" do
      #   process -> (user, message) do
      #
      #   end
      # end
      action OwnerAction

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