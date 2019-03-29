class Policy::Mappings::LocationMapping::Index < Policy::Base

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
    Policy::Mappings::LocationMapping::Index::IndexPresenter.new(user, params, messages)
  end

  class Policy::Mappings::LocationMapping::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :policy

    def init
      self.policy = params[:policy]
    end
  end

end