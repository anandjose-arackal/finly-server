class Superadmin::Base < BaseOperation

  def authorized_user_types
    [:superadmin]
  end

end