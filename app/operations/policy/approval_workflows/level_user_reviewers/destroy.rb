class Policy::ApprovalWorkflows::LevelUserReviewers::Destroy < Policy::ApprovalWorkflows::LevelUserReviewers::Base
  attr_accessor :lurm

  def init
    id = params[:id] || params[:level_user_reviewer_id] || params[:level_user_reviewer_mapping_id]
    self.lurm = Policy::ApprovalWorkflows::LevelUserReviewers::Index.(user, params).lurms.with_id(id).first rescue nil
  end

  def validate
    unless lurm.present?
      add_message :error, "Record not found"
    end
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