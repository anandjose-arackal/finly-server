# This operation would save and then submit the Inward Invoice in one API call

class Procurements::Invoices::SaveSubmit < Procurements::Invoices::Base
  attr_accessor :invoice, :flag_save, :flag_submit

  def init
    invoice_id = params[:id] || params[:invoice_id] || params[:inward_invoice_id]
    self.invoice = user.company.inward_invoices.find_by id: invoice_id
    self.flag_save = false
    self.flag_submit = false
  end

  def validate
    unless self.invoice.present?
      add_message :error, 'Inward Invoice not found'
    end

  end

  def process

    call_save(params)
    return unless self.flag_save    
    call_submit(params)

  end

  def success
    params[:flag_save] = self.flag_save
    params[:flag_submit] = self.flag_submit
    Procurements::Invoices::SaveSubmit::SuccessPresenter.new(user, params, messages)
  end

  def failure
    params[:flag_save] = self.flag_save
    params[:flag_submit] = self.flag_submit
    Procurements::Invoices::SaveSubmit::FailurePresenter.new(user, params, messages)
  end

  class Procurements::Invoices::SaveSubmit::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :flag_save, :flag_submit

    def init
      self.flag_save = params[:flag_save]
      self.flag_submit = params[:flag_submit]
    end 
  end

  class Procurements::Invoices::SaveSubmit::FailurePresenter < BaseOperation::BasePresenter::FailurePresenter
    attr_accessor :flag_save, :flag_submit

    def init
      self.flag_save = params[:flag_save]
      self.flag_submit = params[:flag_submit]
    end 
  end

  private

  def call_save(params)
    op = BankTransfer::InwardInvoices::Update.(user, params)

    op.messages.keys.each do |key|
      add_message key, op.messages[key]      
    end

    self.flag_save = (has_errors?) ? false : true
  end

  def call_submit(params)    
    op = Procurements::Invoices::Submit.(user, params)

    op.messages.keys.each do |key|
      add_message key, op.messages[key]      
    end

    self.flag_submit = (has_errors?) ? false : true
  end

end
