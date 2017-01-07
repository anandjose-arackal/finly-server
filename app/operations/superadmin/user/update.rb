class Superadmin::User::Update < Superadmin::User::Base

  attr_accessor :company, :selected_user, :update_parameters

  def pre_validate
    if user.blank? or params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    self.company = Company.find_by(id: params[:company_id])
    self.selected_user = company.users.find_by(id: params[:id]) if company
    self.update_parameters = update_params
  end

  def authorize
    unless company
      raise_unauthorized_exception
    end
  end

  def validate
    unless selected_user
      add_message :error, "User not found"
      return
    end
  end

  def pre_process
    if selected_user.cards.present? and params[:user][:card_attributes][:proxy].present?
      self.update_parameters[:cards_attributes][0][:id] = selected_user.cards.first.id
    end
  end

  def process
    unless selected_user.update_attributes(update_parameters)
      messages[:error] = selected_user.errors.full_messages
    end
  end

  def post_process
    add_message :success, "User updated"
  end

  def success
    Company::Base::CompanyPresenter.new(user, company: company)
  end

  private

  def update_params
    p = params.require(:user).permit(:first_name, :last_name, :mothers_maiden_name,
                                     profile_attributes: [:date_of_birth, :gender, :address_1,
                                                          :address_2, :city, :state_id, :pin_code])
    if params[:user][:card_attributes][:proxy].present? # todo - also check if the card number matches the Card number format
      p[:cards_attributes] = [{proxy: params[:user][:card_attributes][:proxy],
                               card_type_id: 1,
                               product_code: Constants::ItzCash::PRODUCT_CODE,
                               ending_number: params[:user][:card_attributes][:ending_number],
                               company_id: company.id,
                               active: true
                              }]
    end
    p.permit!
    return p
  end

end
