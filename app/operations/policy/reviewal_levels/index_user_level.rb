class Policy::ReviewalLevels::IndexUserLevel < ReviewalLevels::Base
  attr_accessor :reviewal_levels, :users, :policy

  class Policy::ReviewalLevels::IndexUserLevel::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :reviewal_levels, :users, :paginated_users

    has_scope :filter_policy
    has_scope :filter_associated_entity_type
    # has_scope :reviewal_level_id

    def init
      self.users = params[:users]
      self.reviewal_levels = params[:reviewal_levels]

      if self.reviewal_levels.present?
        self.reviewal_levels = apply_scopes(self.reviewal_levels, params)
        self.reviewal_levels = self.reviewal_levels.non_deleted
        self.reviewal_levels = self.reviewal_levels.order(:level_number)
      end


      page = params[:page] || 1
      per_page = params[:per_page] || 30
      self.paginated_users = self.users.paginate(page: page, per_page: per_page)
    end
  end


  def init
    policy_id = params[:policy_id]
    self.policy = user.company.policies.find_by(id: policy_id)

    unless self.policy.present?
      add_message :error, "Policy not found"
    end

    self.reviewal_levels = ReviewalLevel.with_policy_ids(self.policy.id)

    self.users = User.with_id(self.policy.user_mapping.non_deleted.pluck(:user_id))
  end

  def validate
    
  end

  def success
    params[:users] = self.users
    params[:reviewal_levels] = self.reviewal_levels
    Policy::ReviewalLevels::IndexUserLevel::IndexPresenter.new(user, params, messages)
  end
end