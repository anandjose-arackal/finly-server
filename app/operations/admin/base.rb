class Admin::Base < BaseOperation

  def pre_validate
    # todo - change this before deploying
    unless user.company_id == 1
      raise_unauthorized_exception
    end
  end
end