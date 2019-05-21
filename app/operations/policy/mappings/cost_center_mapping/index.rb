class Policy::Mappings::CostCenterMapping::Index < Policy::Base

  attr_accessor :policy

  def init
    id = params[:id] || params[:policy_id]
    self.policy = Policy.find_by_id id
  end

  def validate
    unless policy.present?
      add_message :error, 'Policy not found'
    end
  end

  def success
    params[:policy] = self.policy
    Policy::Mappings::CostCenterMapping::Index::IndexPresenter.new(user, params, messages)
  end

  class Policy::Mappings::CostCenterMapping::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :policy, :cost_center_mapping, :cost_centers

    def init
      self.policy = params[:policy]
      self.cost_center_mapping = policy.cost_centers
      self.cost_centers = policy.company.cost_centers
    end
  end

end