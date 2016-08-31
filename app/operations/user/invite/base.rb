class User::Invite::Base < BaseOperation

  attr_accessor :invite_params

  def authorized_user_types
    [:manager, :finance_manager, :admin]
  end


  def retrieve
    if is_success?
      return invited_user
    else
      return false
    end
  end

  def create_invite_params
    params.require(:invite).permit(:email, :company_id, :policy_id, team_mapping_attributes: [:default, :manager_id, :finance_manager_id, :approves_to, :approves_finance_to],
                               role_mapping_attributes: [:user_role_id])
  end

end