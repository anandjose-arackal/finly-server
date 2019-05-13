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
class Admin::Users::Import < Admin::Base

  attr_accessor :file, :result_hash, :header, :import_fields, :sheet, :invitee,
                :file_url, :headers, :content

  def authorized_user_types

  end

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << 'No user or params passed'
    end
    if params[:file].nil?
      add_message :error, "No file uploaded, please select a file and try again"
    end
  end


  def init
    self.file = params[:file]
    self.result_hash = {}
    self.sheet = ImportUtil.open_spreadsheet(file)
    self.header = sheet.row(1)
  end

  def authorize

  end

  def validate
    # add a validation for company id in each row
    (2..sheet.last_row).each do |i|
      row = sheet.row(i)
      # validating company id of the new user Type 1
      if company_id_blank?(row)
        result_hash[i] = 1
        next
      end
    end
  end

  def process
    (2..sheet.last_row).each do |i|
      row = sheet.row(i)
      self.params = process_row(row)
      error_messages = params[:error_messages]
      params.delete(:error_messages)

      if result_hash[i].present?
        case result_hash[i]
          when 1
            # i.e. company id not unique
            result_hash[i] = 'Company ID cannot be blank'
            next
          when 2
            # i.e. card has already been taken
            error_messages << 'Card has already been assigned to another user'
            params.delete(:cards_attributes)
          else
            #code
        end
      end

      self.invitee = User.new(params)
      invitee.skip_confirmation_notification!
      invitee.save

      if User.exists?(invitee.id)
        invitee.update_attribute(:default_password, true)
        invitee.update_attribute(:verified, true)
        invitee.confirm
        if error_messages.present?
          result_hash[i] = "User created, but with the following errors: " + error_messages.to_sentence
        else
          result_hash[i] = "Success!"
        end
      else
        result_hash[i] = invitee.errors.full_messages.to_sentence
      end
    end

  end

  def post_process
    # self.file_url = create_response_csv
    self.headers = [
        "first_name".humanize,
        "last_name".humanize,
        "email".humanize,
        "mobile_number".humanize,
        "employee_id".humanize,
        "dob".humanize,
        "address_1".humanize,
        "address_2".humanize,
        "pin_code".humanize,
        "state_id".humanize,
        "city".humanize,
        "gender".humanize,
        "company_id".humanize,
        "department_code".humanize,
        "location_code".humanize,
        "mothers_maiden_name".humanize,
        "expense_management".humanize,
        "disburse ".humanize,
        "vendor_payments".humanize,

    ]
    self.content = []
    (2..sheet.last_row).each do |i|
      self.content << sheet.row(i)
      self.content[i-2] << self.result_hash[i]
    end
  end

  def success
    # params[:file_url] = file_url
    # Admin::Users::Import::FilePresenter.new(user, params, messages)
    self.response = Exporter.new(user, {spreadsheet: {headers: self.headers, contents: self.content}}, messages)
  end

  class Admin::Users::Import::FilePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :file_url

    def init
      self.file_url = params[:file_url]
    end
  end

  private

  def create_response_csv
    file = Tempfile.new("bulk_import_users.csv")
    CSV.open(file.path, 'wb') do |csv|
      self.header << 'Result'
      csv << header
      (2..sheet.last_row).each do |i|
        row = sheet.row(i)
        row = row.map(&:to_s)
        row << result_hash[i]
        csv << row
      end
    end
    temp_file = TemporaryFile.create file: file, expires_on: (DateTime.now.beginning_of_day + 1.day)
    return temp_file.file.url
  end

  def retrieve_invite_type(row)
    if row[import_fields[:email]].present?
      return 'email'
    elsif row[import_fields[:mobile_number]].present?
      return 'mobile'
    else
      # default case is email
      return 'email'
    end
  end

  def company_id_blank?(row)
    if row[import_fields[:company_id]].present?
      return false
    else
      return true
    end
  end

  # generating the parameters that enable the user to be invited
  def process_row(row)
    errors = []

    # converting all elements to strings
    row.each_with_index do |element, index|
      if element.is_a?(Numeric)
        row[index] = element.to_i.to_s
        row[index] = element.to_i.to_s
      end
    end

    role_mapping_attributes = []
    if row[import_fields[:expense_management]]  == 'Y'
     role_mapping_attributes << {user_role_id: UserRole.employee_id,
                                   purpose_id: Purpose.id_for(:expense_management)}
    end
    # adding a default initiator role for vendor payments

    if row[import_fields[:vendor_payments]]  == 'Y'
    role_mapping_attributes << {user_role_id: UserRole.id_for(:initiator),
                                purpose_id: Purpose.id_for(:vendor_payments)}
    end

    user_email = ImportUtil.cleanup_email(row[import_fields[:email]])
    company_id = row[import_fields[:company_id]].to_i rescue nil
    pin_code = row[import_fields[:pin_code]].to_i.to_s if row[import_fields[:pin_code]]
    pin_code ||= nil
    mobile = row[import_fields[:mobile_number]].to_i.to_s if row[import_fields[:mobile_number]]
    mobile ||= nil

    # deciding on whether a particular use is enabled for a particular application - i.e. expense management, disburse, or vendor payments
    expense_management = row[import_fields[:expense_management]] == 'Y' ? true : false
    disburse = row[import_fields[:disburse]] == 'Y' ? true : false
    vendor_payments = row[import_fields[:vendor_payments]] == 'Y' ? true : false

    # generating a password for the user
    generated_password = generate_default_password
    company = Company.find_by(id: row[import_fields[:company_id]])
    department_id = company&.departments&.find_by code: row[import_fields[:department_code]]
    location_id = company&.locations&.find_by location_code: row[import_fields[:location_code]]

    user_department_mappings_attributes = [{ department_id: department_id}]
    user_branch_location_mappings_attributes = [{branch_location_id: location_id}]
    user_params = { first_name: row[import_fields[:first_name]],
                    last_name: row[import_fields[:last_name]],
                    email: user_email,
                    mobile_number: mobile,
                    password: generated_password,
                    password_confirmation: generated_password,
                    profile_attributes: {address_1: row[import_fields[:address_1]],
                                         address_2: row[import_fields[:address_2]],
                                         pin_code: pin_code,
                                         date_of_birth: row[import_fields[:dob]],
                                         state_id: row[import_fields[:state_id]],
                                         gender: row[import_fields[:gender]],
                                         city: row[import_fields[:city]],
                                         employee_id: row[import_fields[:employee_id]]
                    },
                    company_id: row[import_fields[:company_id]],
                    mothers_maiden_name: row[import_fields[:mothers_maiden_name]],
                    error_messages: errors,
                    user_panel_subscription_attributes: {
                        expense_management: expense_management,
                        disburse: disburse,
                        yes_bank_account_transfer: vendor_payments
                    }
    }

    return user_params
  end

  def import_fields    # # i.e. add cards only when the user
    {
        :first_name => 0,
        :last_name => 1,
        :email => 2,
        :mobile_number => 3,
        :dob => 4,
        :employee_id => 5,
        :address_1 => 6,
        :address_2 => 7,
        :pin_code => 8,
        :state_id => 9,
        :city => 10,
        :gender => 11,
        :location_code => 12,
        :department_code => 13,
        :company_id => 14,
        :mothers_maiden_name => 15,
        :expense_management => 16,
        :disburse => 17,
        :vendor_payments => 18
    }
  end

  def generate_default_password(length = 8)
    (0...length).map { (65 + rand(26)).chr }.join
  end

end
