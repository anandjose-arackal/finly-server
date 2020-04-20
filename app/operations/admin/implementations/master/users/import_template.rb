class Admin::Implementations::Master::Users::ImportTemplates < Admin::Implementations::Processor::ImportTemplate

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'users.import_template'
  headers ({
      :id => "ID",
      :first_name => "First Name (mandatory)",
      :last_name => "Last Name (mandatory)",
      :email => "Email",
      :mobile_number => "Mobile Number (mandatory)",
      :employee_id => "Employee ID",
      :dob => "DOB",
      :pan => "PAN",
      :address_1 => "Address Line 1",
      :address_2 => "Address Line 2",
      :pin_code => "PIN CODE",
      :state_id => "State",
      :city => "City",
      :gender => "Gender",
      :company_id => "Company ID (mandatory)",
      :department_code => "Department Name",
      :location_code => "Location Name",
      :cost_center_code => "Cost Center Name",
      :mothers_maiden_name => "Mothers Maiden Name (mandatory)",
      :expense_management => "Expense Management Y for enable",
      :disburse  => "Disburse Y for enable",
      :vendor_payments => "Vendor Payments Y for enable",
      :enforce_policy => 'Enforce Policy',
      :invite => 'Sent Invite',
      :destroy => 'Deactivate (Y for Deactivate/ activate for Activation'
  })

  def valid_request
  end

  def input
    []
  end

  def post_process
  end

end
