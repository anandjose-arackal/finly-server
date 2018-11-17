class Procurements::FilterConfig < Procurements::Base
  attr_accessor :config, :status_tags, :po_statuses, :invoice_statuses

  def init
    self.status_tags = StatusTag.all
    self.po_statuses = PurchaseOrderStatus.all
    self.invoice_statuses = InwardInvoiceStatus.all
  end

  def process
    self.config = {}
    status_tags.each do |tag|
      self.config[tag.name] = tag.id
    end

  end

  def success
    params[:config] = self.config
    params[:po_statuses] = self.po_statuses
    params[:invoice_statuses] = self.invoice_statuses
    Procurements::FilterConfig::ConfigPresenter.new(user, params, messages)
  end

  class Procurements::FilterConfig::ConfigPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :config, :po_statuses, :invoice_statuses

    def init
      self.config = params[:config]
      self.po_statuses = params[:po_statuses]
      self.invoice_statuses = params[:invoice_statuses]
    end
  end
end