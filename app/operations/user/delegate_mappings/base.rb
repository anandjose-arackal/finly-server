class User::DelegateMappings::Base < BaseOperation
  attr_accessor :associated_users

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
    end
  end
end