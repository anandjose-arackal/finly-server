class Invoicing::Analytics::Index < Invoicing::Analytics::Base
  attr_accessor :company, :analytics_data, :invoices, :analytics_params

  def pre_validate
    self.analytics_params = analytics_parameters

    date_from = Date.parse analytics_params[:date_from] rescue nil
    self.analytics_params[:date_from] = date_from || "1990-01-01"
    date_to = Date.parse analytics_params[:date_to] rescue nil
    self.analytics_params[:date_to] = date_to || Date.today

  end

  def init
    self.analytics_data = {}
    self.company = user.company

    self.invoices = company.outward_invoices.filter_date_invoice(analytics_params[:date_from], analytics_params[:date_to])
  end

  def process
    # self.analytics_data[:invoices] = company.outward_invoices.with
    self.analytics_data[:invoices_count] = invoices.count
    self.analytics_data[:paid_invoices_count] = invoices.paid.count
    self.analytics_data[:unpaid_invoices_count] = invoices.unpaid.count
    self.analytics_data[:cancelled_invoices_count] = invoices.cancelled.count
    self.analytics_data[:paritally_paid_invoices_count] = invoices.partially_paid.count

    self.analytics_data[:invoices_total_payable] = invoices.sum_total_payable
    self.analytics_data[:invoices_total_paid] = invoices.sum_total_paid
    self.analytics_data[:invoices_total_balance_due] = invoices.sum_total_balance_due

    self.analytics_data[:customers_created] = company.customers.filter_created_at(analytics_params[:date_from], analytics_params[:date_to]).count

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

  private

  def analytics_parameters
    params.permit(:date_from, :date_to)
  end
end