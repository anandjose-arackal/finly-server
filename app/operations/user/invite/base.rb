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
    [:company_admin, :vendor_payments_admin]
  end

  def success
    User::Invite::Base::InvitePresenter.new(user, {invite: invited_users}, messages)
  end

  def create_invite_params
    params[:pending_invite][:role_mapping_attributes] = [{user_role_id: 4, purpose_id: Purpose.id_for(:expense_management)}]
    if params[:manager] == '1'
      params[:pending_invite][:role_mapping_attributes] << {user_role_id: 3, purpose_id: Purpose.id_for(:expense_management)}
    end
    if params[:finance_manager] == '1'
      params[:pending_invite][:role_mapping_attributes] << {user_role_id: 2, purpose_id: Purpose.id_for(:expense_management)}
    end
    if params[:admin] == '1'
      params[:pending_invite][:role_mapping_attributes] << {user_role_id: 1, purpose_id: Purpose.id_for(:expense_management)}
    end
    if params[:auditor] == '1'
      params[:pending_invite][:role_mapping_attributes] << {user_role_id: UserRole.id_for(:auditor), purpose_id: Purpose.id_for(:expense_management)}
    end

    # adding a default vendor payments initiator role for all invited users
    params[:pending_invite][:role_mapping_attributes] << {user_role_id: UserRole.id_for(:initiator), purpose_id: Purpose.id_for(:vendor_payments)}
    #########################################################################
    unless params[:pending_invite][:team_mapping_attributes].blank?
      params[:pending_invite][:team_mapping_attributes][:default] = true
    end
    params[:pending_invite][:team_mapping_attributes] = [params[:pending_invite][:team_mapping_attributes]]
    params.require(:pending_invite).permit(:email, :mobile, :mobile_number, :company_id, :policy_id, team_mapping_attributes: [:default, :manager_id, :finance_manager_id, :approves_to_id, :approves_finance_to_id],
                               role_mapping_attributes: [:user_role_id])
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation, :invitation_token, :mobile_number, :name)
  end

end