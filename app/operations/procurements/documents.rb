class Procurements::Documents < Procurements::Base
  attr_accessor :procurement, :documents

  def init
    id = params[:id] || params[:procurement_id]

    procurements_index_op = Procurements::Index.(user, params)
    self.procurement = procurements_index_op.procurements.with_ids(id).first

    self.documents = []
  end

  def process
    self.documents.push procurement.purchase_order if procurement.purchase_order.present?
    self.documents.push procurement.invoices if procurement.invoices.present?
    self.documents.push procurement.inward_documents if procurement.inward_documents.present?
    self.documents.push procurement.payments if procurement.payments.present?
  end

  def success
    params[:documents] = self.documents
    Procurements::Documents::ShowPresenter.new(user, params, messages)
  end

  class Procurements::Documents::ShowPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :documents, :results

    def init
      self.documents = params[:documents]

      self.results = []

      self.documents.each do |document|
        self.results.push get_details(document)
      end
    end

    def get_details(document)
      result = {}
      case document.class.name
        when 'PurchaseOrder'
          result[:id] = document.id
          result[:document_number] = document.po_number
          result[:document_status] = document.status.name
          result[:amount] = document.balance_amount&.value
          result[:created_by] = document.user.name
          result[:actions] = get_po_actions(document)
        when 'Invoice'
          result[:id] = document.id
          result[:document_number] = document.invoice_number
          result[:document_status] = document.invoice_status.name
          result[:amount] = document.net_amount&.value
          result[:created_by] = document.created_by.name
          result[:actions] = get_invoice_actions(document)
        when 'InwardDoc'
          result[:id] = document.id
          result[:document_number] = document.invoice_number
          result[:document_status] = document.invoice_status.name
          result[:amount] = document.net_amount&.value
          result[:created_by] = document.created_by.name
          result[:actions] = get_invoice_actions(document)
      end


    end

    def document_owner?
      purchase_order.user_id == user.id
    end

    def user_in_level?
      current_level = purchase_order.level
      amount = purchase_order&.balance_amount&.value || 0

      if current_level.present?
        if current_level.level_reviewer_mappings.with_threshold(amount).pluck(:reviewer_id).include? user.id
          return true
        end
      end

      false
    end

    def get_procurement_trail
      documents = []
      result = []

      if self.purchase_order.present?
        documents << self.purchase_order
      end

      documents += self.inward_documents
      documents += self.invoices

      self.invoices.each do |invoice|
        documents += invoice.payments
      end
      documents += self.bill_of_supplies
      documents += self.delivery_challans
      documents += self.e_way_bills

      documents.sort_by!{ |doc| doc.created_at}.reverse!
      documents
    end
  end
end