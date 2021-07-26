class Companies::Ops::Create < Transactions::API

  step Model(Company, :new)
  # step Transactions::API::AssignModelUser(key: :created_by)
  step Policy::Pundit(Companies::Policy, :create?)
  step Contract::Build(constant: Companies::Contract)
  step Contract::Validate()
  step :set_company_group!
  step Contract::Persist()
  step :enable_vendor_payments!
  step :create_user!
  step Messages::Task::SuccessMessage("Company created")

  def set_company_group!(options, model:, current_user:, **)
    model.group_id = current_user.company.group.id

    true
  end

  def enable_vendor_payments!(options, model:, current_user:, **)
    model.feature_subscription.update_columns(
      yes_bank_account: current_user.company.feature_subscription.yes_bank_account,
      group_entity_structure: current_user.company.feature_subscription.group_entity_structure,
    )

    true
  end

  def create_user!(options, model:, current_user:, **)
    generated_password = SecureRandom.base64 13
    user_params = {
      email: current_user.email,
      company_id: model.id,
      mobile_number: current_user.mobile_number,
      active: true,
      first_name: current_user.first_name,
      last_name: current_user.last_name,
      mothers_maiden_name: current_user.mothers_maiden_name,
      finly_id: current_user.finly_id,
      default_company_id: current_user.default_company_id,
      role_mapping_attributes: [{
        user_role_id: UserRole.id_for(:admin),
        purpose_id: Purpose.id_for(:vendor_payments),
      }, {
        user_role_id: UserRole.id_for(:initiator),
        purpose_id: Purpose.id_for(:vendor_payments),
      }],
      profile_attributes: {
        address_1: current_user.profile.address_1,
        address_2: current_user.profile.address_2,
        pin_code: current_user.profile.pin_code,
        date_of_birth: current_user.profile.date_of_birth,
        state_id: current_user.profile.state_id,
        gender: current_user.profile.gender,
        city: current_user.profile.city,
        employee_id: current_user.profile.employee_id
      },
      user_panel_subscription_attributes: {
        expense_management: current_user.user_panel_subscription&.expense_management,
        disburse: current_user.user_panel_subscription&.disburse,
        yes_bank_account_transfer: current_user.user_panel_subscription&.yes_bank_account_transfer,
      },
      password: generated_password,
      password_confirmation: generated_password,
    }
    new_user = User.new(user_params)
    new_user.skip_confirmation_notification!
    new_user.save!
    new_user.otp_confirm

    new_user.update_columns(encrypted_password: current_user.encrypted_password)

    true
  end

end