class Superadmin::User::Base < Superadmin::Base

  def new_user_params
    params[:user][:role_mapping_attributes] = [{user_role_id: UserRole.employee_id}]

    p = params.require(:user).permit(:email, :password, :password_confirmation, :invitation_token, :mobile_number, :first_name,
                                     :last_name, :mothers_maiden_name,
                                     profile_attributes: [:date_of_birth, :gender, :address_1,
                                                          :address_2, :city, :state_id, :pin_code],
                                     role_mapping_attributes: [:user_role_id])
    if params[:user][:card_attributes][:proxy].present? # todo - also check if the card number matches the Card number format
      p[:cards_attributes] = [{proxy: params[:user][:card_attributes][:proxy],
                               card_type_id: 1,
                               product_code: Constants::ItzCash::PRODUCT_CODE,
                               ending_number: params[:user][:card_attributes][:ending_number],
                               company_id: company.id
                              }]
    end
    p.permit!
    return p
  end

end