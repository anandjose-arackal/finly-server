class ReviewalLevels::Update < ReviewalLevels::Base

  attr_accessor :level

  def init
    id = params[:id] || params[:level_id]

    policy_ids = user.company.policies.pluck(:id)
    reviewal_levels = ReviewalLevel.with_policy_ids(policy_ids)

    self.level = reviewal_levels.find_by id: id
  end

  def validate
    if self.level.blank?
      add_message :error, "Reviewal Level not found"
    end
  end

  def process
    unless self.level.update(update_params)
      add_message :error, self.level.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Level Details Updated"
  end

  def update_params
    params.require(:reviewal_level).permit(:name)
  end

end