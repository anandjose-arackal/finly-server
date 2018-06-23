class Procurements::Show < Procurements::Base
  attr_accessor :procurement

  def init
    id = params[:id] || params[:procurement_id]
    self.procurement = user.company.procurements.find_by id: id
  end

  def process
  end

  def success
    params[:procurement] = self.procurement
    Procurements::Show::ShowPresenter.new(user, params, messages)
  end

  class Procurements::Show::ShowPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :procurement, :purchase_order, :invoices, :inward_documents, :procurement_trail, :locations,
                  :payment_terms, :bill_of_supplies, :delivery_challans,
                  :procurement_terms, :policies

    def init
      self.procurement = params[:procurement]

      # Procurement Documents
      self.purchase_order = self.procurement.purchase_order
      self.invoices = self.procurement.invoices
      self.inward_documents = self.procurement.inward_documents
      self.bill_of_supplies = self.procurement.bill_of_supplies
      self.delivery_challans = self.procurement.delivery_challans

      self.procurement_trail = get_procurement_trail
      self.locations = user.company.locations
      self.payment_terms = user.company.payment_terms
      self.procurement_terms = user.company.procurement_terms

      policies_op = Policy::Index.(user, view: params[:view])
      if policies_op.success?
        self.policies = policies_op.policies
      end

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

      documents.sort_by!{ |doc| doc.created_at}.reverse!
      documents
    end
  end
end