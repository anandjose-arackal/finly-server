class User::DelegateMappings::Base < BaseOperation
  attr_accessor :associated_users

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
    end
    unless user.delegated_for_users.present?
      add_message :error, 'You are not delegated for any user'
      return
    end
  end
end