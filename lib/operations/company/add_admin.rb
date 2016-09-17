class Company::AddAdmin < Company::Base

  attr_accessor :company, :admin

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] = "No user or params passed."
    end
  end

  def init
    self.company = Company.find_by(id: params[:id])
  end

  def authorize
    unless Constants::SUPERADMIN_ACCOUNTS.include?(user.email)
      raise_unauthorized_exception
    end
    unless company
      raise_unauthorized_exception
    end
  end

  def validate

  end

  def process
    self.admin = company.users.build(admin_params)
    if admin.save
      admin.activate
      messages[:success] = "Company created!"
    else
      messages[:error] = "Failed, Try again."
      return false
    end
  end

  def success
    Company::Base::CompanyPresenter.new(user, company: company)
  end

  private

  def admin_params
    params[:admin][:role_mapping_attributes] = [{user_role_id: UserRole.admin_id},
                                                {user_role_id: UserRole.employee_id}]

    params.require(:admin).permit(:name, :email, :password, :password_confirmation,
                                  :mobile_number, team_mapping_attributes: [:default], role_mapping_attributes: [:user_role_id])
  end


end