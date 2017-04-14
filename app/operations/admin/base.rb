class Admin::Base < BaseOperation

  def pre_validate
    # todo - change this before deploying
    jouska_id = Company.find_by(name: "Jouska").id rescue 0
    unless user.company_id == 1 || user.company_id == jouska_id
      raise_unauthorized_exception
    end
  end
end