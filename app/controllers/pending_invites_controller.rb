class PendingInvitesController < ApplicationController

  before_action :authenticate_user!

  def create
    invite_op = User::Invite::Create.new(current_user, params)
    @result = invite_op.run
    respond(response: :success)
  end

  def edit
    @pending_user = User.find_by(email: params[:email])
  end

  def accept
    accept_op = User::Invite::Accept.new(params)
    @result = accept_op.run
    respond(response: :success)
  end

  def resend
    operation = User::Invite::Resend.new(params)
    @result = operation.run
    respond(response: :success)
  end

  def update_invite
    update_invite_op = User::Invite::Update.new(current_user, params)
    @result = update_invite_op.run
    respond(response: :success)
  end

  def destroy
    destroy_op = User::Invite::Destroy.new(current_user, params)
    @result = destroy_op.run
    respond(response: :success)
  end

  private

  def updated_user_invite_params
    params.require(:pending_invite).permit(:email, :company_id, :finance_manager, :manager, :manager_id, :finance_manager_id, :approves_to_id, :approves_finance_to_id, :team_mapping_id)
  end


end
