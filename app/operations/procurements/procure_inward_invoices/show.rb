class Procurements::ProcureInwardInvoices::Show < Procurements::ProcureInwardInvoices::Base
  attr_accessor :invoice

  def init
    invoice_id = params[:id] || params[:invoice_id]
    self.invoice = Invoice.find_by id: invoice_id
  end

  def validate
    unless self.invoice.present?
      add_message :error, 'Invoice not found'
    end
  end

  def success
    params[:invoice] = self.invoice
    Procurements::ProcureInwardInvoices::Show::ShowPresenter.new(user, params, messages)
  end

  class Procurements::ProcureInwardInvoices::Show::ShowPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :invoice, :departments, :sub_departments, :cost_centers

    def init
      self.departments = user.company.departments.roots
      self.sub_departments = user.company.departments.only_sub_departments
      self.cost_centers = user.company.cost_centers
      self.invoice = params[:invoice]
    end
  end
end