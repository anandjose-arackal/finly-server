class User::Invite::Base < BaseOperation

  def authorized_user_types
    [:manager, :finance_manager, :admin]
  end


end