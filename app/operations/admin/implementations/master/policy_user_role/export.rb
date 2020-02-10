class Admin::Implementations::Master::PolicyUserRole::Export < Admin::Implementations::Processor::Export

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'policy_user_role.export'
  has_scope :with_id

  headers ({
      :id => 'ID',
      :policy => 'Policy ID',
      :user_id => 'User Email / Mobile',
      :level_name => 'Level Name',
      :level_number => 'Level Number',
      :reviewer_email_mobile => 'Reviewer Email / Mobile',
      :min => "Minimum Threshold",
      :max => "Max Threshold",
      :destroy => 'Destroy'
  })

  def valid_request

  end

  def input
    policy_ids = apply_scopes(company.policies).pluck(:id)
    level_ids  = ReviewalLevel.non_deleted.where(policy_id: policy_ids,associated_entity: params[:associated_entity]).pluck(:id)
    LevelUserReviewerMapping.where(level_id: level_ids)
  end

  def id(lrm)
    lrm.id
  end

  def policy(lrm)
    lrm.level&.policy&.name
  end

  def level_number(lrm)
    lrm.level&.level_number
  end

  def level_name(lrm)
    lrm.level&.name
  end

  def reviewer_email_mobile(lrm)
    user = lrm.reviewer&.email
    if user.blank?
      lrm.reviewer&.mobile_number
    end
    user
  end

  def destroy(lrm)
    ''
  end

  def post_process
  end

end
