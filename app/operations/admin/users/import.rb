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
                :file_url

  def authorized_user_types

  end

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << 'No user or params passed'
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
    self.file_url = create_response_csv
  end

  def success
    params[:file_url] = file_url
    Admin::Users::Import::FilePresenter.new(user, params, messages)
  end

  class Admin::Users::Import::FilePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :file_url

    def init
      self.file_url = params[:file_url]
    end
  end

  private

  def create_response_csv
    file_name = "public/common/files/temp_files/#{DateUtils.local_date_time}-#{user.id}-result.csv".gsub(Regexp.union([' ', '-', ':', '+']), '')
    CSV.open(file_name, 'wb') do |csv|
      self.header << 'Result'
      csv << header
      (2..sheet.last_row).each do |i|
        row = sheet.row(i)
        row = row.map(&:to_s)
        row << result_hash[i]
        csv << row
      end
    end
    return file_name.gsub('public', '')
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
    manager_email = finance_manager_email = approves_to_email = approves_finance_to_email = nil
    manager_email = ImportUtil.cleanup_email(row[import_fields[:reporting_manager]]) if row[import_fields[:reporting_manager]].present?
    finance_manager_email = ImportUtil.cleanup_email(row[import_fields[:reporting_finance_manager]]) if row[import_fields[:reporting_finance_manager]].present?
    approves_to_email = ImportUtil.cleanup_email(row[import_fields[:approves_to]]) if row[import_fields[:approves_to]].present?
    approves_finance_to_email = ImportUtil.cleanup_email(row[import_fields[:approves_finance_to]]) if row[import_fields[:approves_finance_to]].present?
    user_email = ImportUtil.cleanup_email(row[import_fields[:email]])
    company_id = row[import_fields[:company_id]].to_i rescue nil

    # creating team mapping attributes
    if manager_email
      manager = User.find_by(email: manager_email) rescue nil
      if manager.nil?
        manager = User.find_by(mobile_number: manager_email) rescue nil
      end
      unless manager&.manager? and manager.company_id == company_id
        errors << "Reporting Manager not found / isn't a manager"
        manager = nil
      end
    end
    if finance_manager_email
      finance_manager = User.find_by(email: finance_manager_email) rescue nil
      if finance_manager.nil?
        finance_manager = User.find_by(mobile_number: finance_manager_email) rescue nil
      end
      unless finance_manager&.finance_manager? and finance_manager.company_id == company_id
        errors << "Reporting Finance Manager not found / isn't a finance manager"
        finance_manager = nil
      end
    end
    if approves_to_email
      approves_to = User.find_by(email: approves_to_email) rescue nil
      if approves_to.nil?
        approves_to = User.find_by(mobile_number: approves_to_email)
      end
      unless approves_to&.manager? and approves_to.company_id == company_id
        errors << "Approves to not found / isn't a manager"
        approves_to = nil
      end
    end
    if approves_finance_to_email
      approves_finance_to = User.find_by(email: approves_finance_to_email) rescue nil
      if approves_finance_to.nil?
        approves_finance_to = User.find_by(mobile_number: approves_finance_to_email) rescue nil
      end
      unless approves_finance_to&.finance_manager? and approves_finance_to.company_id == company_id
        errors << "Approves finance to not found / isn't a finance manager"
        approves_finance_to = nil
      end
    end

    pin_code = row[import_fields[:pin_code]].to_i.to_s if row[import_fields[:pin_code]]
    pin_code ||= nil
    mobile = row[import_fields[:mobile_number]].to_i.to_s if row[import_fields[:mobile_number]]
    mobile ||= nil

    # generating a password for the user
    generated_password = generate_default_password
    company = Company.find_by(id: row[import_fields[:company_id]])

    user_params = { first_name: row[import_fields[:first_name]],
                    last_name: row[import_fields[:last_name]],
                    email: user_email,
                    mobile_number: mobile,
                    password: generated_password,
                    password_confirmation: generated_password,
                    role_mapping_attributes: role_mapping_attributes,
                    team_mapping_attributes: [{default: true, manager: manager,
                                               finance_manager: finance_manager,
                                               approves_to: approves_to,
                                               approves_finance_to: approves_finance_to,
                                               policy_id: (company.policies.default.first.id rescue nil)
                                              }],
                    profile_attributes: {address_1: row[import_fields[:address_1]],
                                         address_2: row[import_fields[:address_2]],
                                         pin_code: pin_code,
                                         date_of_birth: row[import_fields[:dob]],
                                         state_id: row[import_fields[:state_id]],
                                         gender: row[import_fields[:gender]],
                                         city: row[import_fields[:city]]
                    },
                    company_id: row[import_fields[:company_id]],
                    mothers_maiden_name: row[import_fields[:mothers_maiden_name]],
                    error_messages: errors
    }

    # # i.e. add cards only when the user
    # if row[import_fields[:card_serial_id]].present?
    #   user_params[:cards_attributes] = [{proxy: row[import_fields[:card_serial_id]],
    #                                      ending_number: row[import_fields[:card_ending_numbers]],
    #                                      company_id: row[import_fields[:company_id]]
    #                                     }]
    # end
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
        :company_id => 18,
        :mothers_maiden_name => 19
    }
  end

  def generate_default_password(length = 8)
    (0...length).map { (65 + rand(26)).chr }.join
  end

end
