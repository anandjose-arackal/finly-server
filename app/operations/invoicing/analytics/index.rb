class Invoicing::Analytics::Index < Invoicing::Analytics::Base
  attr_accessor :company, :analytics_data

  def pre_validate
  end

  def init
    self.analytics_data = {
        invoices_count: 0,
        closed_invoices_count: 0,
        pending_invoices_count: 0,
        partially_paid_invoices_count: 0,

        invoice_amounts: 0,
        invoice_pending_amounts: 0,
        invoice_collected_amounts: 0
    }
    self.company = user.company
  end

  def process
    self.analytics_data[:invoices] = company.outward_invoices.with
    self.analytics_data[:invoices][:invoices_count] = self.analytics_data[:invoices].count
  end

  def success
    params[:analytics_data] = self.analytics_data
    Invoicing::Analytics::Index::IndexPresenter.new(user, params, messages)
  end

  class Invoicing::Analytics::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :analytics_data

    def init
      self.analytics_data = params[:analytics_data]
    end
  end
end