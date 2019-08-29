class Procurements::PurchaseRequests::FilterConfig < Procurements::PurchaseRequests::Base
  attr_accessor :policies

  def init
    self.policies = Policy::VendorPayments::Index.(user, params).policies
  end

  def success
    params[:policies] = self.policies
    Procurements::PurchaseRequests::FilterConfig::ConfigPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseRequests::FilterConfig::ConfigPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :locations, :departments, :cost_centers, :policies

    def init
      self.policies = params[:policies]

      config_op = Configs::LocDept.(user, params)

      self.locations = config_op.locations
      self.departments = config_op.departments
      self.cost_centers = config_op.cost_centers
    end
  end
end