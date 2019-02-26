class Policy::ReviewalLevels::ShowUserLevel < Policy::ReviewalLevels::Base
  attr_accessor :reviewal_levels, :target_user, :policy

  class Policy::ReviewalLevels::IndexUserLevel::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :reviewal_levels, :target_user, :paginated_users, :levels_data

    has_scope :filter_policy
    has_scope :filter_associated_entity_type
    # has_scope :reviewal_level_id

    def init
      self.target_user = params[:target_user]
      self.reviewal_levels = params[:reviewal_levels]

      if self.reviewal_levels.present?
        self.reviewal_levels = apply_scopes(self.reviewal_levels, params)
        self.reviewal_levels = self.reviewal_levels.non_deleted
        self.reviewal_levels = self.reviewal_levels.order(:level_number)
      end

      self.levels_data = []
      self.reviewal_levels.each do |level|
        data = {
          level_number: level.level_number,
          id: level.id,
          level: level,
          lrms: level.level_reviewer_mappings.non_deleted.includes(:reviewer)
        }
        self.levels_data.push(data)
      end
    end
  end

  def authorized_user_types
    [:admin]
  end

  def init
    policy_id = params[:policy_id]
    user_id = params[:user_id]
    self.policy = user.company.policies.find_by(id: policy_id)

    unless self.policy.present?
      add_message :error, "Policy not found"
    end

    self.target_user = User.with_id(self.policy.user_mapping.non_deleted.pluck(:user_id)).with_id(params[:user_id]).first rescue nil
    self.reviewal_levels = ReviewalLevel.with_policy_ids(self.policy.id)
  end

  def validate
    unless self.target_user.present?
      add_message :error, "Invalid user details found"
    end
  end

  def success
    params[:target_user] = self.target_user
    params[:reviewal_levels] = self.reviewal_levels
    Policy::ReviewalLevels::IndexUserLevel::IndexPresenter.new(user, params, messages)
  end
end