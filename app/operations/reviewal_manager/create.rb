class ReviewalManager::Create < ReviewalManager::Base
  attr_accessor :reviewal_params

  def init
    self.reviewal_params = reviewal_parameters

    policy_id = reviewal_params[:policy_id]
    self.policy = user.company.policies.with_id(policy_id).first

    unless policy.present?
      add_message :error, 'Policy not found'
      return
    end
    highest_level = policy.levels.order(level_number: :desc).first

  end

  private

  def reviewal_parameters
    params.require(:reviewal_workflow).permit(:id, :level_number, :policy_id, :reviewer_id, :entity_type)
  end

end