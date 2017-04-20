class Admin::Base < BaseOperation

  def pre_validate
    unless user.finly_admin? || user.company_id == 1
      raise_unauthorized_exception
    end
  end
end