# operation to mass import user details onto the system
# Sheet columns:
  # First name:
  # Last name:
  # Email:
  # Mobile number:
  # Date of birth:
  # Address:
  # PIN Code:
  # Manager? : Y/N based on whether the user is a manager
  # Finance Manager? : Y/N based on whether the user is a finance manager
  # Admin? : Y/N based on whether the user is a admin
  # Reporting manager: Email id of the reporting manager
  # Reporting finance manager: Email id of the reporting finance manager
  # Approves to: Email id of the approves to user
  # Approves finance to: Email id of the approves finance to user
  # Card serial ID: Serial ID of the card being assigned to the user

# roo is the gem that lets us import csv's and xls's

require 'roo'
class Import::Users < Import::Base
  attr_accessor :file, :result_hash, :header, :import_fields, :sheet

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
      if type == 'email'
        invitee = user.company.users.invite!(params)
      elsif type == 'mobile'

      end

      if User.exists?(invitee.id)
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

  def retrieve_invite_type(row)
    if row[import_fields[:email]].present?
      return 'email'
    elsif
      row[import_fields[:mobile_number]].present?
      return 'mobile'
    else
      # default case is email
      return 'email'
    end
  end

  def generate_response_csv
    CSV.generate(headers: true) do |csv|
      self.header << "Result"
      csv << header
      (2..sheet.last_row).each do |i|
        row = sheet.row(i)
        row << result_hash[i]
        csv << row
      end
    end
  end

  def open_spreadsheet(file)
    case File.extname(file.original_filename)
      when ".csv" then Roo::Csv.new(file.path)
      when ".xls" then Roo::Excel.new(file.path)
      when ".xlsx" then Roo::Excelx.new(file.path)
      else raise "Unknown file type: #{file.original_filename}"
    end
  end

  # generating the parameters that enable the user to be invited
  def process_row(row)
    errors = []

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
      unless manager and manager.manager?
        errors << "Reporting Manager not found"
        manager = nil
      end
    end
    if row[import_fields[:reporting_finance_manager]]
      finance_manager = User.find_by(email: row[import_fields[:reporting_finance_manager]]) rescue nil
      unless finance_manager and finance_manager.finance_manager?
        errors << "Reporting Finance Manager not found"
        finance_manager = nil
      end
    end
    if row[import_fields[:approves_to]]
      approves_to = User.find_by(email: row[import_fields[:approves_to]]) rescue nil
      unless approves_to and approves_to.manager?
        errors << "Approves to not found / isn't a manager"
        approves_to = nil
      end
    end
    if row[import_fields[:approves_finance_to]]
      approves_finance_to = User.find_by(email: row[import_fields[:approves_finance_to]]) rescue nil
      unless approves_finance_to and approves_finance_to.finance_manager?
        errors << "Approves finance to not found / isn't a finance manager"
        approves_finance_to = nil
      end
    end

    user_params = { first_name: row[import_fields[:first_name]],
                    last_name: row[import_fields[:last_name]],
                    email: row[import_fields[:email]],
                    mobile_number: row[import_fields[:mobile_number]],
                    role_mapping_attributes: role_mapping_attributes,
                    team_mapping_attributes: [{default: true, manager: manager,
                                                              finance_manager: finance_manager,
                                                              approves_to: approves_to,
                                                              approves_finance_to: approves_finance_to
                                             }],
                    profile_attributes: {address_1: row[import_fields[:address_1]],
                                         address_2: row[import_fields[:address_2]],
                                         pin_code: row[import_fields[:pin_code]],
                                         date_of_birth: row[import_fields[:dob]],
                                         state_id: row[import_fields[:state_id]],
                                         gender: row[import_fields[:gender]],
                                         city: row[import_fields[:city]]
                                        },
                    cards_attributes: [{proxy: row[import_fields[:card_serial_id]],
                                      card_type_id: 1,
                                      product_code: "NGPRHD",
                                      ending_number: row[import_fields[:card_serial_id]].last(4)
                                      }],
                    error_messages: errors
                  }
    return user_params
  end

  def import_fields
    { 
      :first_name => 0,
      :last_name => 1,
      :email => 2,
      :mobile_number => 3,
      :dob => 4,
      :address_1 => 5,
      :address_2 => 6,
      :pin_code => 7,
      :state_id => 8,
      :city => 9,
      :gender => 10,
      :manager_role => 11,
      :finance_manager_role => 12,
      :admin_role => 13,
      :reporting_manager => 14,
      :reporting_finance_manager => 15,
      :approves_to => 16,
      :approves_finance_to => 17,
      :card_serial_id => 18
   }
  end

end


