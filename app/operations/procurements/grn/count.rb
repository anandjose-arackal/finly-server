class Procurements::Grn::Count < Procurements::Base

  attr_accessor :count, :status_count

  class Procurements::Grn::Count::CountPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :count, :status_count

    def init
      self.count = params[:count]
      self.status_count = params[:status_count]
    end
  end

  def pre_validate
    unless user.company.feature_subscription.receipt_note_mandatory
      add_message :error, "Receipt note is not enabled for your company. Please contact your admin or Finly Customer Support."
      return
    end
  end

  def process
    params[:filter_procurement_type] = "purchase_order"
    params[:filter_status_tags] = [7, 2, 3] # [StatusTag.id_for(:receiving_shipment), StatusTag.id_for(:po_approved), StatusTag.id_for(:po_sent)]

    # REFACTORING NEEDED
    # SEPRATE OPERATIONS ARE USED TO GET GRN PENDING & RECEIVED
    # CREATE OPERATION : Procurements::Grns::Index which should work for both
    #

    # Temporary statues till code is refactored

    shipment_received = Procurements::Grn::Received::Index.(user, params)&.count || 0
    receiving_shipment = Procurements::Grn::Pending::Index.(user, params)&.count || 0
    status_count = {
      receiving_shipment: receiving_shipment,
      shipment_received: shipment_received
    }
    # result = Procurements::Grn::Pending::Index.(user, params)
    self.count = receiving_shipment
    self.status_count = status_count
    
  end

  def success
    params[:count] = self.count
    params[:status_count] = self.status_count
    Procurements::Grn::Count::CountPresenter.new(user, params, messages)
  end

end