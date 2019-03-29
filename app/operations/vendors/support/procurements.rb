class Vendors::Support::Procurements < Vendors::Support::Base
  attr_accessor :procurements, :vendor

  class Vendors::Support::Procurements::ProcurementsPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :data

    def init
      self.vendor = params[:vendor]
      self.data = get_procurement_data
    end

    def get_procurement_data
      data = {}
      data[:purchase_orders] = Procurements::PurchaseOrders::Index.(user, {filter_vendor_id: self.vendor.id}).purchase_orders
      data[:po_invoices] = Procurements::Invoice::Index.(user, {filter_vendor_id: self.vendor.id, filter_inward_invoice_type: 'tax_invoice'}).invoices
      data[:non_po_invoices] = Procurements::Invoices::Index.(user, {filter_vendor_id: self.vendor.id, filter_inward_invoice_type: 'non_po_invoice'}).invoices
      data
    end
  end

  def init
    self.vendor = Vendors::Show.(user, params).vendor
  end

  def validate
    unless self.vendor.present?
      add_message :error, "Vendor Not Found"
    end
  end

  def success
    params[:vendor] = self.vendor
    Vendors::Support::Procurements::ProcurementsPresenter.new(user, params, messages)
  end
end