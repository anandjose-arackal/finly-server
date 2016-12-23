class Company::AddAdmin < Company::Base

  attr_accessor :company, :admin

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "No user or params passed."
    end
  end

  def init
    self.company = Company.find_by(id: params[:id] || params[:company_id])
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
    admin.skip_confirmation_notification!
    if admin.save
      admin.activate
      messages[:success] << "New admin created!"
    else
      messages[:error] = admin.errors.full_messages
    end
  end

  def success
    Company::Base::CompanyPresenter.new(user, company: company)
  end

  def post_process
    # if the admin has a card, activate that card
    if admin.cards.present?
      admin.cards.first.update_attributes(active: true)
    end
  end

  private

  def admin_params
    params[:user][:role_mapping_attributes] = [{user_role_id: UserRole.admin_id},
                                                {user_role_id: UserRole.employee_id}]

    p = params.require(:user).permit(:email, :password, :password_confirmation, :invitation_token, :mobile_number, :first_name,
                                 :maiden_name, :last_name,
                                 profile_attributes: [:date_of_birth, :gender, :address_1,
                                                      :address_2, :city, :state_id, :pin_code],
                                 role_mapping_attributes: [:user_role_id])
    if params[:user][:card_attributes][:proxy].present? # todo - also check if the card number matches the Card number format
      p[:cards_attributes] = [{proxy: params[:user][:card_attributes][:proxy],
                               card_type_id: 1,
                               product_code: "NGPRHD",
                               ending_number: params[:user][:card_attributes][:ending_number],
                               company_id: company.id
                              }]
    end
    p.permit!
    return p
  end

end