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
    attr_accessor :procurement, :purchase_order, :invoices, :inward_documents

    def init
      self.procurement = params[:procurement]
      self.purchase_order = self.procurement.purchase_order
      self.invoices = self.procurement.invoices
      self.inward_documents = self.procurement.inward_documents
    end
  end
end