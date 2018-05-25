class Procurements::Base < BaseOperation

  def success
    params[:procurement] = self.procurement
    Procurements::Base::BasePresenter.new(user, params, messages)
  end

  class Procurements::Base::BasePresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :procurement, :purchase_order, :inward_documents, :tax_invoices

    def init
      self.procurement = params[:procurement]
      self.purchase_order = procurement.purchase_order
      self.inward_documents = procurement.inward_documents
      # self.invoices = procurement.invoices
    end

  end
end