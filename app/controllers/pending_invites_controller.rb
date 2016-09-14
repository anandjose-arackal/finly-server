class PendingInvitesController < ApplicationController

  before_action :authenticate_user!

  def create
    @result = User::Invite::Create.(current_user, params)
    respond(response: :success)
  end

  # def edit
  #   @pending_user = User.find_by(email: params[:email])
  # end

  def accept
    @result = User::Invite::Accept.(params)
    respond(response: :success)
  end

  def resend
    @result = User::Invite::Resend.(params)
    respond(response: :success)
  end

  def update_invite
    @result = User::Invite::Update.(current_user, params)
    respond(response: :success)
  end

  def destroy
    @result = User::Invite::Destroy.(current_user, params)
    respond(response: :success)
  end

  private
  def updated_user_invite_params
    params.require(:pending_invite).permit(:email, :company_id, :finance_manager, :manager, :manager_id, :finance_manager_id, :approves_to_id, :approves_finance_to_id, :team_mapping_id)
  end

end
