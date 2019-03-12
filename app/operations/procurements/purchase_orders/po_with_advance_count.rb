class Procurements::PurchaseOrders::PoWithAdvanceCount < Procurements::PurchaseOrders::Base

  attr_accessor :count, :status_count

  class Procurements::PurchaseOrders::PoWithAdvanceCount::CountPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :count, :status_count

    def init
      self.count = params[:count]
      self.status_count = params[:status_count]
    end
  end

  def process

    result = Procurements::PurchaseOrders::PoWithAdvance.(current_user, params)
    if result.success?
      self.count = result.purchase_order.size
      self.status_count = result.get_status_counts
    else
      add_message :error, result.messages[:error]
    end
  end

  def success
    params[:count] = self.count
    params[:status_count] = self.status_count
    Procurements::PurchaseOrders::PoWithAdvanceCount::CountPresenter.new(user, params, messages)
  end
end

