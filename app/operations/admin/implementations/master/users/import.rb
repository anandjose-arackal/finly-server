class Admin::Implementations::Master::Users::Import < Admin::Implementations::Processor::Import

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'users.import'
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
      :expense_management => "Expense Management Y for enable",
      :disburse  => "Disburse Y for enable",
      :vendor_payments => "Vendor Payments Y for enable"
  })

  attr_accessor :user_params

  def create_record(data)
    user_params, messages = set_params(data)
    unless messages.blank?
      return result false, messages.join(', ')
    end
    user = self.company.users.build(user_params)
    unless user.validate
      return result false, user.errors.full_messages
    end
    begin
      unless user.save
        return result false, user.errors.full_messages
      end
    rescue Exception => e
      return result false, e.message
    end
    result true, 'Created Successfully'
  end

  def update_record(data)
    user = self.company.users.find_by id: data[:id]
    unless user
      return result false, "User not found"
    end
    user_params, messages = set_params(data)
    unless messages.blank?
      return result false, messages.join(', ')
    end

    begin
      unless user.update(user_params)
        return result false, user.errors.full_messages
      end
    rescue Exception => e
      return result false, e.message
    end

    result true, 'Updated Successfully'
  end

   def set_params(data)
    messages = []
    role_mapping_attributes = []
    if data[:expense_management] == 'Y'
      role_mapping_attributes << {user_role_id: UserRole.employee_id,
                                  purpose_id: Purpose.id_for(:expense_management)}
    end
    # adding a default initiator role for vendor payments

    if data[:vendor_payments]  == 'Y'
      role_mapping_attributes << {user_role_id: UserRole.id_for(:initiator),
                                  purpose_id: Purpose.id_for(:vendor_payments)}
    end

    user_email = ImportUtil.cleanup_email(data[:email])
    company_id = data[:company_id].to_i rescue nil
    pin_code = data[:pin_code].to_i.to_s if data[:pin_code]
    pin_code ||= nil
    mobile = data[:mobile_number].to_i.to_s if data[:mobile_number]
    mobile ||= nil

    # deciding on whether a particular use is enabled for a particular application - i.e. expense management, disburse, or vendor payments
    expense_management = data[:expense_management] == 'Y' ? true : false
    disburse = data[:disburse] == 'Y' ? true : false
    vendor_payments = data[:vendor_payments] == 'Y' ? true : false

    unless expense_management || disburse || vendor_payments
      messages << "One of the application needs to enabled"
    end

    # generating a password for the user
    generated_password = generate_default_password
    company = Company.find_by(id: data[:company_id])
    department_id = company&.departments&.find_by department_code: data[:department_code]
    location_id = company&.locations&.find_by location_code: data[:location_code]
    if company.nil?
      messages << "Company with this ID not found"
    end
    if data[:department_code].present? && department_id.nil?
      messages << "Department with code not found"
    end

    if data[:location_code_code].present? && location_id.nil?
      messages << "Location with code not found"
    end

    state_id = nil
    if data[:state_id].present?
      state_id = State.where('name LIKE ?', "%#{data[:state_id]}%")&.first&.id
      unless  state_id.present?
        messages << "Invalid State Name"
      end
    end

    user_department_mappings_attributes = [{ department_id: department_id}]
    user_branch_location_mappings_attributes = [{branch_location_id: location_id}]
    user_params = { first_name: data[:first_name],
                    last_name: data[:last_name],
                    email: user_email,
                    mobile_number: mobile,
                    password: generated_password,
                    password_confirmation: generated_password,
                    role_mapping_attributes: role_mapping_attributes,
                    profile_attributes: {address_1: data[:address_1],
                                         address_2: data[:address_2],
                                         pin_code: pin_code,
                                         date_of_birth: data[:dob],
                                         state_id: state_id,
                                         gender: data[:gender],
                                         city: data[:city],
                                         employee_id: data[:employee_id]
                    },
                    company_id: data[:company_id],
                    mothers_maiden_name: data[:mothers_maiden_name],
                    user_panel_subscription_attributes: {
                        expense_management: expense_management,
                        disburse: disburse,
                        yes_bank_account_transfer: vendor_payments
                    }
    }

    [user_params, messages]
  end

  def generate_default_password
    SecureRandom.base64 13
  end

end
