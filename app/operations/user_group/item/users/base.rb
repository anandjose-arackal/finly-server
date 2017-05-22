class UserGroup::Item::Users::Base < BaseOperation

  def authorized_user_types
    :company_admin
  end

end