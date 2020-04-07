class ExportManager::Master::PaymentAgreements::Index < ExportManager::Builders::Spreadsheet

  label 'Export'
  description 'Agreements Export'
  configurable true
  handle :invoices
  screen 'payment_agreements.index'
  system :vp
  validate :fetch_invoices

  section :header do
    attribute :agreement_number
    attribute :tittle
    attribute :policy
    attribute :agreement_date
    attribute :status
    attribute :execution_date
    attribute :expiration_date
    attribute :never_expire
    attribute :renewal_date
    attribute :renewal_reminder

  end

  section :general_invoice do
    attribute :invoice_number
    attribute
  end

  section :rental_invoices do
    attribute :test
  end

  section :custom_fields do
    attribute :custom_fields, dynamic: true
  end

  def custom_fields(row, invoice_line_item)
  end

  def fetch_invoices
    agreement_presenter = PaymentAgreements::Index.(user, params)
    unless agreement_presenter.success?
      add_message :error, agreement_presenter.messages[:error]
      return
    end
    agreement_presenter
  end

  def input
    fetch_invoices
  end

end