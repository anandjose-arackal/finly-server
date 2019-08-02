class ReminderSubmitPending < ApplicationJob
  def perform
    remind_submit_pending_grn
    remind_submit_pending_invoice
  end

  def remind_submit_pending_grn
    User.where(company_id: 156).each do |user|
      params = { inward_documents:  }
      Event::EInwardDocument::SubmitPending.(user, params) if params.fetch(:inward_documents).present?
    end
  end

  def remind_submit_pending_invoice
    User.where(company_id: 156).each do |user|
      params = { invoices:  }
      Event::EInvoice::SubmitPending.(user, params) if params.fetch(:invoices).present?
    end
  end


end