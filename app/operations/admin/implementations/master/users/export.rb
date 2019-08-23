class Admin::Implementations::Master::Users::Export < Admin::Implementations::Processor::Export

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'users.export'

  headers ({
      :id => "ID",
      :first_name => "First Name (mandatory)",
      :last_name => "Last Name (mandatory)",
      :email => "Email",
      :mobile_number => "Mobile Number (mandatory)",
      :employee_id => "Employee ID",
      :dob => "DOB",
      :address_1 => "Address Line 1",
      :address_2 => "Address Line 2",
      :pin_code => "PIN CODE",
      :state_id => "State",
      :city => "City",
      :gender => "Gender",
      :company_id => "Company ID (mandatory)",
      :department_code => "Department Code",
      :location_code => "Location Code",
      :mothers_maiden_name => "Mothers Maiden Name (mandatory)",
      :expense_management => "Expense",
      :disburse  => "Disburse",
      :vendor_payments => "Vendor Payments"
  })

  def valid_request

  end

  def input
    company.users
  end

  def id(user)
    user.id
  end

  def first_name(user)
    user.first_name
  end

  def last_name(user)
    user.last_name
  end

  def email(user)
    user.email
  end

  def mobile_number(user)
    user.mobile_number
  end

  def address_1(user)
    user.address_1 rescue ''
  end

  def address_2(user)
    user.address_2 rescue ''
  end

  def employee_id(user)
    user.profile&.employee_id
  end

  def dob(user)
    user.date_of_birth&.strftime("%d-%m-%y") rescue ''
  end

  def pin_code(user)
    user.pin_code rescue ''
  end

  def city(user)
    user.city rescue ''
  end

  def state_id(user)
    user.state_id rescue ''
  end

  def gender(user)
    user.gender_name rescue ''
  end

  def company_id(user)
    user.company_id
  end

  def department_code(user)
    ''
  end

  def location_code(user)
    ''
  end

  def mothers_maiden_name(user)
    user.mothers_maiden_name rescue ''
  end

  def expense_management(user)
    user.user_panel_subscription.expense_management? ? 'Y' : ''
  end

  def disburse(user)
    user.user_panel_subscription.disburse? ? 'Y' : ''
  end

  def vendor_payments(user)
    user.user_panel_subscription.yes_bank_account_transfer? ? 'Y' : ''
  end

  def post_process
  end

end
