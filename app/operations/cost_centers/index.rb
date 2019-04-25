class CostCenters::Index < CostCenters::Base

  attr_accessor :cost_centers

  class CostCenters::Index::CostCenterPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :cost_centers

    def init
      self.cost_centers = params[:cost_centers]
    end
  end

  def process
    self.cost_centers = company.cost_centers
  end

  def user_model
    [User, AdminUser]
  end

  def success
    params[:cost_centers] = self.cost_centers
    CostCenters::Index::CostCenterPresenter.new(user, params, messages)
  end
end