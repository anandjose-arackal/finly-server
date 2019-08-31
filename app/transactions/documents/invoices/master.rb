class Documents::Invoices::Master < Documents::Master

  document Invoice
  form Documents::Invoices::Form
  policy Documents::Invoices::Policy
  scope :admin, Documents::Invoices::Policy::Scope
  scope Documents::Invoices::Policy::Scope
  system_events :submit, :approve
  request_events :index, :show
  event_workflow Documents::Invoices::Workflows::Email
  event_workflow Documents::Invoices::Workflows::Export

end