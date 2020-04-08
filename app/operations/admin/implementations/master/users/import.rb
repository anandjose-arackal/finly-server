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
      :destroy => 'Deactivate (Y for Deactivate / activate for Activation)'
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
      user.update(default_password: true, verified: true)
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
      unless user.update(user_params.except(:password, :password_confirmation))
        return result false, user.errors.full_messages
      end
    rescue Exception => e
      return result false, e.message
    end

    result true, 'Updated Successfully'
  end

  def destroy_records(data)
    user = self.company.users.find_by id: data[:id]
    unless user
      return result false, "User not found"
    end
    if data[:destroy]&.to_s&.downcase  == 'y'
      unless user.update(active: false)
        return result false, user.errors.full_messages
      end
      result true, "Deactivated Successfully"
    elsif data[:destroy]&.to_s&.downcase == 'activate'
      unless user.update(active: true)
        return result false, user.errors.full_messages
      end
      return result true, "Activated Successfully"
    end
  end

  def invite(data)
    invited_user = self.company.users.find_by id: data[:id]
    unless invited_user.present?
      return result false, "User not found"
    end

    unless invited_user.email.present?
      return result false, "User not have an email"
    end

    user_params = {user_id: invited_user.id}
    presenter = Admin::Users::WelcomeMail.(AdminUser.all.first, user_params)
    if presenter.messages[:error].present?
      return result false, presenter.messages[:error].join(' ,')
    elsif presenter.messages[:failure].present?
      return result false, presenter.messages[:failure].join(' ,')
    elsif presenter.messages[:success].present?
      return result true, "User Invited Successfully"
    end
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
    if data[:id].blank?
      generated_password = generate_default_password
    else
      generated_password = ''
    end
    company = Company.find_by(id: data[:company_id])
    department_id = company&.departments&.find_by(name: data[:department_code])&.id
    location_id = company&.locations&.find_by(name: data[:location_code])&.id
    cost_center_id =  company&.cost_centers&.find_by(name: data[:cost_center_code])&.id
    enforce_policy_enabled = data[:enforce_policy]&.to_s&.upcase == 'Y' ? true : false
    if company.nil?
      messages << "Company with this ID not found"
    end
    if data[:department_code].present? && department_id.nil?
      messages << "Department not found"
    end

    if data[:location_code].present? && location_id.nil?
      messages << "Location not found"
    end

    if data[:cost_center_code].present? && cost_center_id.nil?
      messages << "Cost Center not found"
    end

    state_id = nil
    if data[:state_id].present?
      state_id = State.where('name LIKE ?', "%#{data[:state_id]}%")&.first&.id
      unless  state_id.present?
        messages << "Invalid State Name"
      end
    end

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
                                         pan: data[:pan],
                                         state_id: state_id,
                                         gender: data[:gender],
                                         city: data[:city],
                                         employee_id: data[:employee_id]
                    },
                    company_id: data[:company_id],
                    mothers_maiden_name: data[:mothers_maiden_name],
                    location_id: location_id,
                    department_id: department_id,
                    cost_center_id: cost_center_id,
                    user_panel_subscription_attributes: {
                        expense_management: expense_management,
                        disburse: disburse,
                        yes_bank_account_transfer: vendor_payments
                    },
                    enforce_policy_attributes:{
                        enforceable_type: "User",
                        enabled: enforce_policy_enabled
                    }
    }

    [user_params, messages]
  end

  def generate_default_password
    char_array = [("a".."z").to_a,
                  ("A".."Z").to_a,
                  ("0".."9").to_a,
                  %q(#?!@$%^&*-).chars]
    all_values  = char_array.flatten
    arr=[]
    6.times.map do
      arr = char_array.map(&:sample)
      (5 - char_array.size).times{ arr << all_values.sample}
      arr.shuffle.join
    end
    "#{arr.join()}#{SecureRandom.base64(10)}"
  end

end
