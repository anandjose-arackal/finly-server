class Procurements::BillOfSupplies::Show < Procurements::BillOfSupplies::Base
  attr_accessor :bill_of_supply

  class Procurements::BillOfSupplies::Show::ShowPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :bill_of_supply

    def init
      self.bill_of_supply = params[:bill_of_supply]
    end
  end

  def init
    bill_of_supply_id = params[:id] || params[:bill_of_supply_id]

    self.bill_of_supply = BillOfSupply.find_by id: bill_of_supply_id

  end

  def validate
    unless self.bill_of_supply.present?
      add_message :error, 'Bill of Supply not found'
    end
  end

  def success
    params[:bill_of_supply] = self.bill_of_supply
    Procurements::BillOfSupplies::Show::ShowPresenter.new(user, params, messages)
  end
end