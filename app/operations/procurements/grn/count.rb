class Procurements::Grn::Count < Procurements::Base

  attr_accessor :count, :status_count

  class Procurements::Grn::Count::CountPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :count, :status_count

    def init
      self.count = params[:count]
      self.status_count = params[:status_count]
    end
  end

  def process
    params[:filter_procurement_type] = "purchase_order"
    params[:filter_status_tags] = [7, 2, 3] # [StatusTag.id_for(:receiving_shipment), StatusTag.id_for(:po_approved), StatusTag.id_for(:po_sent)]
    result = Procurements::Grn::Pending::Index.(user, params)
    if result.success?
      self.count = result.procurements.size
      self.status_count = result.get_status_counts
    else
      add_message :error, result.messages[:error]
    end 
  end

  def success
    params[:count] = self.count
    params[:status_count] = self.status_count
    Procurements::Grn::Count::CountPresenter.new(user, params, messages)
  end

end