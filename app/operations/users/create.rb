# Used to create users without invitation
class Users::Create < Admin::Users::Create

  def user_model
    User
  end

  def authorized_user_types
    [:company_admin]
  end

  def init
    self.company = user.company
    self.new_user_params = parse_user_params
  end

  def pre_process
    # set dummy password for this user that will be reset on OTP verification
    self.new_user_params[:password] = "dummypassword"
    self.new_user_params[:password_confirmation] = "dummypassword"

    self.new_user_params.permit!
  end

  def process
    self.created_user = self.company.users.build(new_user_params)
    created_user.skip_confirmation_notification!
    if created_user.save
      created_user.activate
      # created_user.otp_confirm
      created_user.update(verified: true, default_password: true)
    else
      add_message :error, created_user.errors.full_messages
      return
    end
  end

  def post_process
    add_message :success, "User successfully created"
  end

  # success method will be automatically picked up from the Admin::Users::Create operation

  private

  def parse_user_params
    user_params = params.permit(:email, :mobile_number, :first_name, :last_name, :mothers_maiden_name)
    user_params[:profile_attributes] = params.permit(:date_of_birth, :gender, :address_1,
                                                     :address_2, :city, :state_id, :pin_code, :employee_id, :payroll_id)

    user_params[:role_mapping_attributes] = []
    # setting roles for expense management
    expense_role_params = params[:expense_management_roles]
    user_params[:role_mapping_attributes] << {user_role_id: UserRole.id_for(:admin), purpose_id: Purpose.id_for(:expense_management)} if expense_role_params&.dig(:admin)
    user_params[:role_mapping_attributes] << {user_role_id: UserRole.id_for(:finance_manager), purpose_id: Purpose.id_for(:expense_management)} if expense_role_params&.dig(:finance_manager)
    user_params[:role_mapping_attributes] << {user_role_id: UserRole.id_for(:manager), purpose_id: Purpose.id_for(:expense_management)} if expense_role_params&.dig(:manager)
    user_params[:role_mapping_attributes] << {user_role_id: UserRole.id_for(:employee), purpose_id: Purpose.id_for(:expense_management)} # because initiator role will be there irrespective

    # setting roles for vendor payments
    vendor_payment_role_params = params[:vendor_payments_roles]
    user_params[:role_mapping_attributes] << {user_role_id: UserRole.id_for(:admin), purpose_id: Purpose.id_for(:vendor_payments)} if vendor_payment_role_params&.dig(:admin)
    user_params[:role_mapping_attributes] << {user_role_id: UserRole.id_for(:creditor), purpose_id: Purpose.id_for(:vendor_payments)} if vendor_payment_role_params&.dig(:creditor)
    user_params[:role_mapping_attributes] << {user_role_id: UserRole.id_for(:reviewer), purpose_id: Purpose.id_for(:vendor_payments)} if vendor_payment_role_params&.dig(:reviewer)
    user_params[:role_mapping_attributes] << {user_role_id: UserRole.id_for(:initiator), purpose_id: Purpose.id_for(:vendor_payments)} # because initiator role will be there irrespective

    # adding user panel subscription based on what is passed in the front end
    user_params[:user_panel_subscription_attributes] = {expense_management: !!params[:expense_management],
                                                        disburse: !!params[:disburse_panel],
                                                        yes_bank_account_transfer: !!params[:vendor_payments],
                                                        invoicing_system: !!params[:invoicing]}

    user_params
  end

end