class Admin::Base < BaseOperation

  def pre_validate
    # todo - change this before deploying
    jouska_id = user.company_id == Company.find_by(name: "Jouska").id
    unless user.company_id == 1
      raise_unauthorized_exception
    end
  end
end