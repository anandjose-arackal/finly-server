module Documents::Invoices::Consumers::Submit::Mailers

  class SubmitMailer < Events::Mailer
    # document Invoice
    queue 'invoice.submit'
    # from 'noreply@finly.io'

  end

  # class Owner < SubmitMailer
  #   document Invoice
  #   consume 'invoice.submit'
  #   schedule every: 1.day, at: {hour: 12, min: 0}
  #   from 'noreply@finly.io'
  #   configuration_key 'invoice.submit.owner'
  #   run_if -> (invoice) {invoice.status_id == InwardInvoiceStatus.id_for(:processing)}
  #   to -> (invoice) {invoice.user}
  #   template 'mailers/document'
  #   subject -> (invoice) {"Invoice #{invoice.invoice_number} submitted for approval"}
  #   body -> (){}
  # end
  #
  # class AutoApproval < SubmitMailer
  #   configuration_key 'invoice.submit.owner'
  #   run_if -> (invoice) {invoice.status_id == InwardInvoiceStatus.id_for(:processing)}
  #   to -> (invoice) {invoice.user}
  #   from 'noreply@finly.io'
  #   subject -> (invoice) {"Invoice #{invoice.invoice_number} submitted for approval"}
  #   template 'mailers/document'
  # end

  # class Reviewer < Events::Mailer
  #   configuration_key 'invoice.submit.reviewer'
  #   run_if -> (invoice) {invoice.status_id == InwardInvoiceStatus.id_for(:processing)}
  #   to -> (invoice) {invoice.user}
  #   from 'noreply@finly.io'
  #   subject -> (invoice) {"You have successfully submitted invoice #{invoice.invoice_number} for approval"}
  #   template 'mailers/document'
  # end
  #
  #
  # class Reminder < Events::Mailer
  #   scheduled!
  #   configuration_key 'invoice.reviewer.reminders'
  #   run_if -> (invoice) {invoice.status_id == InwardInvoiceStatus.id_for(:processing)}
  #   to -> (invoice) {invoice.user}
  #   from 'noreply@finly.io'
  #   subject -> (invoice) {"You have successfully submitted invoice #{invoice.invoice_number} for approval"}
  #   template 'mailers/document'
  # end

end