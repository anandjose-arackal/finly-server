class Admin::Implementations::Master::Lrms::Export < Admin::Implementations::Processor::Export

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'lrms.export'
  has_scope :with_id

  headers [
              :id,
              :policy,
              :level_name,
              :level_number,
              :reviewer_email_mobile,
              :destroy
          ]

  def valid_request

  end

  def input
    policy_ids = apply_scopes(company.policies).pluck(:id)
    level_ids  = ReviewalLevel.non_deleted.where(policy_id: policy_ids).pluck(:id)
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
