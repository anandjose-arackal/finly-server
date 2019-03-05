class BankTransfer::InwardInvoices::Count < BankTransfer::InwardInvoices::Base

  attr_accessor :count, :status_count, :po_invoice_count, :non_po_invoice_count

  def init
    params[:type] = params[:filter_invoice_type]
    params.delete(:filter_invoice_type)
    op = BankTransfer::InwardInvoices::Index.(user, params)
    if op.success?      
      self.count = op.invoices.count
      self.po_invoice_count = op.invoices.filter_invoice_type('po_invoice').count      
      self.non_po_invoice_count = op.invoices.filter_invoice_type('non_po_invoice').count
      case params[:type]
      when 'po_invoice'        
        self.status_count = op.po_invoice_status_count
        self.status_count["all"] = sprintf '%02d', self.po_invoice_count
      when 'non_po_invoice'
        self.status_count = op.non_po_invoice_status_count
        self.status_count["all"] = sprintf '%02d', self.non_po_invoice_count
      end
    else
      self.count = 0
    end
  end

  # def success
  #   self.count
  #   self.status_count
  # end
  def success
    params[:count] = self.count
    params[:status_count] = self.status_count
    params[:po_invoice_count] = sprintf '%02d', self.po_invoice_count
    params[:non_po_invoice_count] = sprintf '%02d', self.non_po_invoice_count
    BankTransfer::InwardInvoices::Count::CountPresenter.new(user, params, messages)
  end


  class BankTransfer::InwardInvoices::Count::CountPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :count, :status_count, :po_invoice_count, :non_po_invoice_count

    def init
      self.count = params[:count]
      self.status_count = params[:status_count]
      self.po_invoice_count = params[:po_invoice_count]
      self.non_po_invoice_count = params[:non_po_invoice_count]
    end
  end


end