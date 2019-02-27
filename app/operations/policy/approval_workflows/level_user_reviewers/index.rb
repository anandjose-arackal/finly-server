class Policy::ApprovalWorkflows::LevelUserReviewers::Index < Policy::ApprovalWorkflows::LevelUserReviewers::Base
  attr_accessor :lurms

  def authorized_user_types
    [:admin]
  end

  def init
    self.level_user_reviewer_params = generate_params
    policy_ids = user.company.policies.non_deleted.pluck(:id)

    reviewal_level_ids = ReviewalLevel.with_policy_id(policy_ids)

    self.lurms = LevelUserReviewerMapping.with_level_id(reviewal_level_ids)
  end

  def success
    params[:lurms] = self.lurms
    Policy::ApprovalWorkflows::LevelUserReviewers::Index::IndexPresenter.new(user, params, messages)
  end

  class Policy::ApprovalWorkflows::LevelUserReviewers::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :lurms

    def init
      self.lurms = params[:lurms]
    end    
  end
end