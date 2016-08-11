class PendingInvitesController < ApplicationController

  before_action :authenticate_user!
  before_action :load_service_objects
  before_action :valid_token, only: [:edit, :update]

  def create
    if @user_invite_service.invite(user_invite_params)
      flash[:success] = "User invited!"
    else
      debugger
      flash[:error] = @user_invite_service.errors
    end
    redirect_to request.referer
  end

  def edit
    @pending_user = User.find_by(email: params[:email])
  end

  def update
    if @user_invite_service.accept_invitation(user_params)
      flash[:success] = "Registration done!"
      redirect_to root_url
    else
      flash[:error] = @user_invite_service.errors
      render_flash_message
    end
  end

  def update_invite
    user_id = params[:pending_invite_id]
    if @user_invite_service.update_invite(user_id, updated_user_invite_params)
      flash[:success] = "Invite updated!"
      redirect_to request.referrer
    else
      flash[:error] = @user_invite_service.errors
      render_flash_message
    end
  end


  def destroy

  end

  private

  def user_invite_params
    params[:pending_invite][:role_mapping_attributes] = [{user_role_id: 4}]
    if params[:manager] == '1'
      params[:pending_invite][:role_mapping_attributes] << {user_role_id: 3}
    end
    if params[:finance_manager] == '1'
      params[:pending_invite][:role_mapping_attributes] << {user_role_id: 2}
    end
    if params[:admin] == '1'
      params[:pending_invite][:role_mapping_attributes] << {user_role_id: 1}
    end
    params[:pending_invite][:team_mapping_attributes] = [{default: true, manager_id: params[:pending_invite][:manager_id],
                                                          finance_manager_id: params[:pending_invite][:finance_manager_id],
                                                          approves_to_user_id: params[:pending_invite][:approves_to_user_id],
                                                          approves_finance_to_user_id: params[:pending_invite][:approves_finance_to_user_id]}]
    params.require(:pending_invite).permit(:email, :company_id, :policy_id, role_mapping_attributes: [:user_role_id],
                                           team_mapping_attributes: [:default, :manager_id, :finance_manager_id,
                                                                     :approves_to_user_id, :approves_finance_to_user_id])
  end

  def updated_user_invite_params
    params.require(:pending_invite).permit(:email, :company_id, :finance_manager, :manager, :manager_id, :finance_manager_id, :approves_to_user_id, :approves_finance_to_user_id, :team_mapping_id)
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation, :invitation_token, :mobile_number, :name)
  end

  def valid_token

  end

  def load_service_objects
    @user_invite_service = UserInviteService.new(current_user)
  end

end
