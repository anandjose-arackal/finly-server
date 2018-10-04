class User::Update < Admin::Users::Update

  attr_accessor :user_params

  def authorized_user_types
    [:company_admin]
  end

  def init
    self.company = user.company
    id = params[:id] || params[:user_id]
    self.selected_user = self.company.users.find_by(id: id)
    self.user_params = parse_user_params
  end

  def process
    if selected_user.update(user_params)
      selected_user.confirm
      add_message :success, "User updated"
    else
      add_message :error, selected_user.errors.full_messages
      return
    end
  end

  def post_process
    add_message :success, "User successfully updated"
  end

  private

  def parse_user_params
    user_params = params.permit(:email, :mobile_number, :first_name, :last_name, :mothers_maiden_name)
    user_params[:profile_attributes] = params.permit(:date_of_birth, :gender, :address_1,
                                                     :address_2, :city, :state_id, :pin_code, :employee_id, :payroll_id)
    user_params
  end
end