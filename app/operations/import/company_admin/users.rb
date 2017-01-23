class Import::CompanyAdmin::Users < Import::Superadmin::Users

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "No user or params passed."
    end
  end


  def init
    self.file = params[:file]
    self.result_hash = {}
    self.sheet = open_spreadsheet(file)
    self.header = sheet.row(1)
  end

  def authorize

  end

  def validate

  end

  def process
    (2..sheet.last_row).each do |i|
      row = sheet.row(i)
      type = retrieve_invite_type(row)
      self.params = process_row(row)
      error_messages = params[:error_messages]
      params.delete(:error_messages)

      unique = mobile_number_valid?(row[import_fields[:mobile_number]])

      if unique == true
        if type == 'email'
          self.invitee = user.company.users.invite!(params)
        elsif type == 'mobile'
          self.invitee = user.company.users.invite!(params, user) do |u|
            u.skip_invitation
            u.update_attribute(:email, "")
            u.update_attribute(:mobile_only_invite, true)
            # send welcome message to invitee
            WelcomeMessage::Create.(user, {mobile_number: [params[:mobile_number]]})
          end
        end
      end

      if unique.is_a?(String)
        result_hash[i] = "This mobile number is already taken"
      elsif User.exists?(invitee.id)
        if error_messages.present?
          result_hash[i] = "User invited, but with the following errors: " + error_messages.to_sentence
        else
          result_hash[i] = "Success!"
        end
      else
        result_hash[i] = invitee.errors.full_messages.to_sentence
      end
    end
  end

  def post_process
    # generating the success csv
    self.response = generate_response_csv
  end

  private

  # generating the parameters that enable the user to be invited
  def process_row(row)
    errors = []

    # converting all elements to strings
    row.each_with_index do |element, index|
      if element.is_a?(Numeric)
        row[index] = element.to_i.to_s
      end
    end

    # creating role mapping attributes
    role_mapping_attributes = [{user_role_id: UserRole.employee_id}]
    if row[import_fields[:manager_role]] and row[import_fields[:manager_role]].downcase == "y"
      role_mapping_attributes << {user_role_id: UserRole.manager_id}
    end
    if row[import_fields[:finance_manager_role]] and row[import_fields[:finance_manager_role]].downcase == "y"
      role_mapping_attributes << {user_role_id: UserRole.finance_manager_id}
    end
    if row[import_fields[:admin_role]] and row[import_fields[:admin_role]].downcase == "y"
      role_mapping_attributes << {user_role_id: UserRole.admin_id}
    end


    manager = finance_manager = approves_to = approves_finance_to = nil
    # creating team mapping attributes
    if row[import_fields[:reporting_manager]]
      manager = User.find_by(email: row[import_fields[:reporting_manager]]) rescue nil
      if manager.nil?
        manager = User.find_by(mobile_number: row[import_fields[:reporting_manager]]) rescue nil
      end
      unless manager and manager.manager? and manager.company_id == user.company_id
        errors << "Reporting Manager not found / isn't a manager"
        manager = nil
      end
    end
    if row[import_fields[:reporting_finance_manager]]
      finance_manager = User.find_by(email: row[import_fields[:reporting_finance_manager]]) rescue nil
      if finance_manager.nil?
        finance_manager = User.find_by(mobile_number: row[import_fields[:reporting_manager]]) rescue nil
      end
      unless finance_manager and finance_manager.finance_manager? and finance_manager.company_id == user.company_id
        errors << "Reporting Finance Manager not found / isn't a finance manager"
        finance_manager = nil
      end
    end
    if row[import_fields[:approves_to]]
      approves_to = User.find_by(email: row[import_fields[:approves_to]]) rescue nil
      if approves_to.nil?
        approves_to = User.find_by(mobile_number: row[import_fields[:mobile_number]])
      end
      unless approves_to and approves_to.manager? and approves_to.company_id == user.company_id
        errors << "Approves to not found / isn't a manager"
        approves_to = nil
      end
    end
    if row[import_fields[:approves_finance_to]]
      approves_finance_to = User.find_by(email: row[import_fields[:approves_finance_to]]) rescue nil
      if approves_finance_to.nil?
        approves_finance_to = User.find_by(mobile_number: row[import_fields[:approves_finance_to]]) rescue nil
      end
      unless approves_finance_to and approves_finance_to.finance_manager? and approves_finance_to.company_id == user.company_id
        errors << "Approves finance to not found / isn't a finance manager"
        approves_finance_to = nil
      end
    end

    mobile = row[import_fields[:mobile_number]].to_i.to_s if row[import_fields[:mobile_number]]
    mobile ||= nil

    user_params = { email: row[import_fields[:email]],
                    mobile_number: mobile,
                    role_mapping_attributes: role_mapping_attributes,
                    team_mapping_attributes: [{default: true, manager: manager,
                                               finance_manager: finance_manager,
                                               approves_to: approves_to,
                                               approves_finance_to: approves_finance_to
                                              }],
                    error_messages: errors
                  }

    return user_params
  end

  def import_fields
    {
        :email => 0,
        :mobile_number => 1,
        :manager_role => 2,
        :finance_manager_role => 3,
        :admin_role => 4,
        :reporting_manager => 5,
        :reporting_finance_manager => 6,
        :approves_to => 7,
        :approves_finance_to => 8,
    }
  end

end