class LevelUserReviewersController < BaseControllers::WebBase

  # Create LURM (Override for reviewer in levels)
  def create
    @result = Policy::ApprovalWorkflows::LevelUserReviewers::Create.(current_user, params)
    respond
  end

  # Update LURM
  def update
    @result = Policy::ApprovalWorkflows::LevelUserReviewers::Update.(current_user, params)
    respond
  end

  # Destroy LURM
  def destroy
    @result = Policy::ApprovalWorkflows::LevelUserReviewers::Destroy.(current_user, params)
    respond
  end

  # params {
  #   reviewal_document: document, # Optional if provider_name is provided
  #   provider_name: provider_name, # Optional if reviewal_document if provided
  #   policy_id: policy_id, # Mandatory
  # }
  # Return possible levels w/ reviewers and their thresholds for the passed values
  def index
    @result = ReviewalManager::ReviewalChain.(current_user, params)
  end
end