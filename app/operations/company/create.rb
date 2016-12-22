class Company::Create < Company::Base

  attr_accessor :company, :admin

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << 'No user or params passed'
    end
  end

  def init

  end

  def authorize
    unless Constants::SUPERADMIN_ACCOUNTS.include?(user.email)
      raise_unauthorized_exception
    end
  end

  def validate
    if User.find_by_email(admin_params[:email]).present?
      messages[:error] << 'User is already registered to company'
    end
  end

  def process
    self.company = Company.new(company_params)
    unless company.save
      add_message :error, company.errors.full_messages
      return
    end
    self.admin = company.users.build(admin_params)
    admin.skip_confirmation_notification!
    if company.save && admin.save
      admin.activate
      messages[:success] << 'Company and admin created successfully!'
    else
      messages[:error] = company.errors.full_messages + admin.errors.full_messages
    end
  end

  def success
    Company::Base::CompanyPresenter.new(user, company: company)
  end

  private

  def company_params
    params.require(:company).permit(:name)
  end

  def admin_params
    params[:user][:role_mapping_attributes] = [{user_role_id: UserRole.admin_id},
                                                {user_role_id: UserRole.employee_id}]

    params.require(:user).permit(:email, :password, :password_confirmation, :invitation_token, :mobile_number, :first_name,
                                 :maiden_name, :last_name,
                                 profile_attributes: [:date_of_birth, :gender, :address_1,
                                                      :address_2, :city, :state_id, :pin_code],
                                 role_mapping_attributes: [:user_role_id])
  end


end