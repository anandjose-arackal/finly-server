class Procurements::EWayBills::Show < Procurements::EWayBills::Base
  attr_accessor :e_way_bill

  class Procurements::EWayBills::Show::ShowPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :e_way_bill

    def init
      self.e_way_bill = params[:e_way_bill]
    end
  end

  def init
    e_way_bill_id = params[:id] || params[:e_way_bill_id]

    self.e_way_bill = EWayBill.find_by id: e_way_bill_id

  end

  def validate
    unless self.e_way_bill.present?
      add_message :error, 'E Way Bill not found'
    end
  end

  def success
    params[:e_way_bill] = self.e_way_bill
    Procurements::EWayBills::Show::ShowPresenter.new(user, params, messages)
  end
end