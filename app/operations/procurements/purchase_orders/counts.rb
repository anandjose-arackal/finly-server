class Procurements::PurchaseOrders::Count < Procurements::Base
  attr_accessor :count, :status_count, :data

  def process
    result = Procurements::PurchaseOrders::Index.(user, params)

    if result.success?
      self.data = result.get_counts
    end
  end

  def success
    params[:data] = self.data
    Procurements::PurchaseOrders::Count::CountPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseOrders::Count::CountPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :data

    def init
      self.data = params[:data]
    end
  end
end

