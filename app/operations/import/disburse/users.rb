class Import::Disburse::Users < Import::Base

  attr_accessor :file_url, :company_id

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "No user or params passed."
    end
  end

  def init
    super
    self.file = params[:file]
    self.result_hash = {}
    if file.present?
      self.sheet = open_spreadsheet(file)
      self.header = sheet.row(1)
    end
  end

  def authorize

  end

  def validate
    if file.nil? || sheet.nil?
      add_message :error, 'No file uploaded, please attach a file and try again'
    end
  end

  def pre_process

  end

  def process
    (2..sheet.last_row).each do |i|
      row = sheet.row(i)
      type = retrieve_invite_type(row)
      self.params = process_row(row)
      ##### adding default policy id to team mapping ##
      params[:team_mapping_attributes][0][:policy_id] = user.company.policies.default.first.id rescue nil
      #################################################
      error_messages = params[:error_messages]
      params.delete(:error_messages)

      unique = mobile_number_valid?(row[import_fields[:mobile_number]])

      if unique == true
        self.invitee = User.new(params)
        self.invitee.skip_confirmation_notification!
        invitee.default_password = true
        invitee.verified = true
        if type == 'email'
          self.invitee.save
        elsif type == 'mobile'
          invitee.save
          invitee.update_attribute(:email, "")
          invitee.update_attribute(:mobile_only_invite, true)
        end
      end

      if unique.is_a?(String)
        result_hash[i] = unique
      elsif User.exists?(invitee.id)
        if error_messages.present?
          result_hash[i] = "User invited, but with the following errors: " + error_messages.to_sentence
        else
          result_hash[i] = "Success"
        end
      else
        result_hash[i] = invitee.errors.full_messages.to_sentence
      end
    end
  end

  def post_process
    # generating the success csv
    self.file_url = create_response_csv
  end

  def success
    params[:file_url] = file_url
    Import::CompanyAdmin::Users::FilePresenter.new(user, params, messages)
  end

  class Import::CompanyAdmin::Users::FilePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :file_url

    def init
      self.file_url = params[:file_url]
    end
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
    role_mapping_attributes = [{user_role_id: UserRole.employee_id, purpose_id: MappingPurpose.id_for(:expense_management)}]
    if row[import_fields[:manager_role]] and row[import_fields[:manager_role]].downcase == "y"
      role_mapping_attributes << {user_role_id: UserRole.manager_id, purpose_id: MappingPurpose.id_for(:expense_management)}
    end
    if row[import_fields[:finance_manager_role]] and row[import_fields[:finance_manager_role]].downcase == "y"
      role_mapping_attributes << {user_role_id: UserRole.finance_manager_id, purpose_id: MappingPurpose.id_for(:expense_management)}
    end
    if row[import_fields[:admin_role]] and row[import_fields[:admin_role]].downcase == "y"
      role_mapping_attributes << {user_role_id: UserRole.admin_id, purpose_id: MappingPurpose.id_for(:expense_management)}
    end

    # adding a default initiator role for users in vendor payments
    role_mapping_attributes << {user_role_id: UserRole.id_for(:initiator), purpose_id: MappingPurpose.id_for(:vendor_payments)}

    manager = finance_manager = approves_to = approves_finance_to = nil
    # creating team mapping attributes
    if row[import_fields[:reporting_manager]]
      manager = User.find_by(email: row[import_fields[:reporting_manager]]) rescue nil
      if manager.nil?
        manager = User.find_by(mobile_number: row[import_fields[:reporting_manager]]) rescue nil
      end
      unless manager&.manager? and manager.company_id == user.company_id
        errors << "Reporting Manager not found / isn't a manager"
        manager = nil
      end
    end
    if row[import_fields[:reporting_finance_manager]]
      finance_manager = User.find_by(email: row[import_fields[:reporting_finance_manager]]) rescue nil
      if finance_manager.nil?
        finance_manager = User.find_by(mobile_number: row[import_fields[:reporting_manager]]) rescue nil
      end
      unless finance_manager&.finance_manager? and finance_manager.company_id == user.company_id
        errors << "Reporting Finance Manager not found / isn't a finance manager"
        finance_manager = nil
      end
    end
    if row[import_fields[:approves_to]]
      approves_to = User.find_by(email: row[import_fields[:approves_to]]) rescue nil
      if approves_to.nil?
        approves_to = User.find_by(mobile_number: row[import_fields[:mobile_number]])
      end
      unless approves_to&.manager? and approves_to.company_id == user.company_id
        errors << "Approves to not found / isn't a manager"
        approves_to = nil
      end
    end
    if row[import_fields[:approves_finance_to]]
      approves_finance_to = User.find_by(email: row[import_fields[:approves_finance_to]]) rescue nil
      if approves_finance_to.nil?
        approves_finance_to = User.find_by(mobile_number: row[import_fields[:approves_finance_to]]) rescue nil
      end
      unless approves_finance_to&.finance_manager? and approves_finance_to.company_id == user.company_id
        errors << "Approves finance to not found / isn't a finance manager"
        approves_finance_to = nil
      end
    end

    mobile = row[import_fields[:mobile_number]].to_i.to_s if row[import_fields[:mobile_number]]
    mobile ||= nil

    password = generate_default_password(8)

    user_params = { email: row[import_fields[:email]],
                    mobile_number: mobile,
                    password: password,
                    password_confirmation: password,
                    first_name: row[import_fields[:first_name]],
                    last_name: row[import_fields[:last_name]],
                    mothers_maiden_name: "To be filled",
                    role_mapping_attributes: role_mapping_attributes,
                    team_mapping_attributes: [{default: true, manager: manager,
                                               finance_manager: finance_manager,
                                               approves_to: approves_to,
                                               approves_finance_to: approves_finance_to,
                                               policy_id: company.policies.first.id,
                                               purpose_id: MappingPurpose.id_for(:expense_management)
                                              },
                                              {
                                                  default: true,
                                                  manager: nil,
                                                  finance_manager: nil,
                                                  approves_to: nil,
                                                  approves_finance_to: nil,
                                                  policy_id: company.policies.first.id,
                                                  purpose_id: MappingPurpose.id_for(:vendor_payments)
                                              }
                                              ],
                    company_id: self.company_id,
                    profile_attributes: {
                          date_of_birth: "01-01-2000",
                          gender: "m",
                          address_1: "To be filled",
                          address_2: "To be filled",
                          city: "To be filled",
                          state_id: 1,
                          pin_code: "110005"
                    },
                    user_panel_subscription_attributes: {
                        expense_management: false,
                        disburse: true,
                        yes_bank_account_transfer: false
                    },
                    error_messages: errors
    }

    return user_params
  end

  def import_fields
    {
        :email => 0,
        :mobile_number => 1,
        :first_name => 2,
        :last_name => 3,
        :manager_role => 4,
        :finance_manager_role => 5,
        :admin_role => 6,
        :reporting_manager => 7,
        :reporting_finance_manager => 8,
        :approves_to => 9,
        :approves_finance_to => 10,
    }
  end

  def generate_default_password(length = 8)
    (0...length).map { (65 + rand(26)).chr }.join
  end
end