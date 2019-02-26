class Policy::ReviewalLevels::LevelUserReviewers::Destroy < Policy::ReviewalLevels::LevelUserReviewers::Base
  attr_accessor :level_user_reviewer

  def init
    id = params[:id] || params[:level_user_reviewer_id] || params[:level_user_reviewer_mapping_id]
    self.level_user_reviewer = ::LevelUserReviewerMapping.find_by id: id
  end

  def validate
    
  end

  def process
    unless level_user_reviewer.destroy
      add_message :error, "Couldn't remove override"
    end
  end

  def post_process
    add_message :success, "Removed Override"
  end
end