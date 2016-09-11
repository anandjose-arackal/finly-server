class PendingInvitesController < ApplicationController

  before_action :authenticate_user!

  def create
    invite_op = User::Invite::Create.new(current_user, params)
    if invite_op.run
      flash[:success] = "User invited!"
      respond_to do |format|
        format.json {render json: {"success": true}}
      end
    else
      flash[:error] = invite_op.errors
      respond_to do |format|
        format.json {render json: {"success": true, errors: invite_op.errors}}
      end
    end
    # redirect_to request.referer
  end

  def edit
    @pending_user = User.find_by(email: params[:email])
  end

  # def update
  #   if @user_invite_service.accept_invitation(user_params)
  #     flash[:success] = "Registration done!"
  #     redirect_to root_url
  #   else
  #     flash[:error] = @user_invite_service.errors
  #     render_flash_message
  #   end
  # end

  def accept
    accept_op = User::Invite::Accept.new(params)
    if accept_op.run
      redirect_to root_url
    else
      flash[:error] = accept_op.errors
      # render the flash message
    end
  end

  def update_invite
    update_invite_op = User::Invite::Update.new(current_user, params)
    if update_invite_op.run
      flash[:success] = "Invite updated!"
      redirect_to request.referrer
    else
      flash[:error] = update_invite_op.errors
      # render the flash message
    end
  end


  def destroy
    destroy_op = User::Invite::Destroy.new(current_user, params)
    if destroy_op.run
      flash[:success] = "Invite deleted!"
      redirect_to request.referrer
    else
      flash[:error] = destroy_op.errors
      # render flash
    end
  end

  private

  def updated_user_invite_params
    params.require(:pending_invite).permit(:email, :company_id, :finance_manager, :manager, :manager_id, :finance_manager_id, :approves_to_id, :approves_finance_to_id, :team_mapping_id)
  end


end
