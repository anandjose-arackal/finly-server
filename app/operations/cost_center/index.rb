class CostCenter::Index < CostCenter::Base

  attr_accessor :cost_centers

  class CostCenter::Index::CostCenterPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :cost_centers

    def init
      self.cost_centers = params[:cost_centers]
    end
  end

  def init
    self.cost_centers = user.company.cost_centers
  end
end