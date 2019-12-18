class User::Update < User::Base

  attr_accessor :user_params, :selected_user, :company

  class User::Update::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :updated_user

    def init
      self.updated_user = params[:updated_user]
    end
  end

  def pre_validate

  end

  def user_model
    User
  end

  def authorized_user_types
    [:company_admin, :admin, :vendor_payments_admin]
  end

  def init
    self.company = user.company
    id = params[:id] || params[:user_id]

    case RequestStore.store[:current_app]
    when 'em', :em
      result = User::Show.(user, params)
    when 'vp', :vp
      result = BankTransfer::Users::Show.(user, params)
    end

    unless result.success?
      add_message :error, result.messages[:error]
      return
    end

    self.selected_user = result.selected_user
    self.user_params = parse_user_params
    self.user_params[:first_name], self.user_params[:last_name] = split_name params.dig(:user, :name)

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

  def success
    params[:updated_user] = self.selected_user
    User::Update::SuccessPresenter.new(user, params, messages)
  end

  private

  def parse_user_params
    user_params = params.require(:user).permit(:email, :mobile_number, :first_name, :last_name, :mothers_maiden_name, profile_attributes: [:id, :date_of_birth, :gender, :address_1,
                                                                                                                                           :address_2, :city, :state_id, :pin_code, :employee_id, :payroll_id])
    user_params
  end

  def split_name(full_name)
    name_array = full_name.split(' ')

    if name_array.count > 1
      first_name = name_array.shift
      last_name = name_array.join(' ')
    else
      first_name = name_array.first
      last_name = ""
    end

    return [first_name, last_name]
  end

end