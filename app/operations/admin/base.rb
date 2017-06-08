class Admin::Base < BaseOperation

  def pre_validate
    unless user.finly_admin?
      raise_unauthorized_exception
    end
  end
end