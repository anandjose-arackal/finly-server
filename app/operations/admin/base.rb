class Admin::Base < BaseOperation

  def pre_validate
    # todo - change this before deploying
    unless user.company_id == 1 || user.company_id == Company.find_by(name: "Jouska").id
      raise_unauthorized_exception
    end
  end
end