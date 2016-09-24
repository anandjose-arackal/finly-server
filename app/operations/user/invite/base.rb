# base class for user inviting operations
#

class User::Invite::Base < BaseOperation

  attr_accessor :invite_params

  class User::Invite::Base::InvitePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invite, :accepted_user

    def init
      self.invite = params[:invite]
      self.accepted_user = params[:accepted_user]
    end
  end

  def authorized_user_types
    [:company_admin]
  end

  def success
    User::Invite::Base::InvitePresenter.new(user, {invite: invited_user}, messages)
  end

  def create_invite_params
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
    params[:pending_invite][:team_mapping_attributes][:default] = true
    params[:pending_invite][:team_mapping_attributes] = [params[:pending_invite][:team_mapping_attributes]]
    params.require(:pending_invite).permit(:email, :company_id, :policy_id, team_mapping_attributes: [:default, :manager_id, :finance_manager_id, :approves_to_id, :approves_finance_to_id],
                               role_mapping_attributes: [:user_role_id])
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation, :invitation_token, :mobile_number, :name)
  end

end