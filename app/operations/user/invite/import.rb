# operation to mass import user details onto the system
# Sheet columns:
  # email: user email
  # name: Full name of the employee
  # Manager: User's reporting manager
  # Finance Manager: User's finance manager
  # Assign Manager Role? : Yes/No depending on whether user is supposed to be manager or not
  # Assign Finance Manager role?: Yes/No depending on whether user is supposed to be a finance manager or not
  # Policy: If the user is to be added to a particular policy as well.


require 'roo'
class User::Invite::Import < BaseOperation
  attr_accessor :file, :success_hash

  def authorized_user_types
    [:manager, :finance_manager, :admin]
  end

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "No user or params passed."
    end
  end


  def init
    self.file = params[:file]
    self.success_hash = {}
  end

  def authorize

  end

  def validate
    # check file type
  end

  def process
    sheet = open_spreadsheet(params[:file])
    self.header = sheet.row(1)
    (2..sheet.last_row).each do |i|
      row = Hash[[header, sheet.row(i)].transpose]
      row[:role_mapping_attributes] = [{user_role_id: UserRole.employee_id}]
      row = process_row(row)
      row[:team_mapping_attributes] = [row[:team_mapping_attributes]]
      user = User.invite!(row.to_hash)
      if user
        success_hash[i] = "success!"
      else
        success_hash[i] = user.errors.full_messages
      end
    end
  end

  def post_process
    # generating the success csv
    self.response = generate_response_csv
  end


  private

  def generate_response_csv
    CSV.generate(headers: true) do |csv|
      sheet = open_spreadsheet(params[:file])
      headers = sheet.row(1)
      headers << "Result"
      csv << headers
      (2..sheet.last_row).each do |i|
        row = sheet.row(i)
        row << success_hash[i]
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

  # method that adds the user attributes as required by active record
  def process_row(row)
    # if the excel has company name instead of company id
    if row['company'].present?
      company_id = Company.where('lower(name) = ?', row['company'].downcase).first.id rescue nil
      if company_id
        row[:company_id] = company_id
      end
      row.delete('company')
    end
    if row['manager'].present?
      row[:team_mapping_attributes] = {} unless row[:team_mapping_attributes]
      row[:team_mapping_attributes][:default] = true
      manager_id = user.company.users.where('lower(name) = ?', row['manager'].downcase).first.id rescue nil
      if manager_id
        row[:team_mapping_attributes][:manager_id] = manager_id
      end
      row.delete('manager')
    end
    if row['finance_manager'].present?
      row[:team_mapping_attributes] = {} unless row[:team_mapping_attributes]
      row[:team_mapping_attributes][:default] = true
      finance_manager_id = user.company.users.where('lower(name) = ?', row['finance_manager'].downcase).first.id rescue nil
      if finance_manager_id
        row[:team_mapping_attributes][:finance_manager_id] = finance_manager_id
      end
      row.delete('finance_manager')
    end
    if row['policy'].present?
      policy_id = user.company.policies.where('lower(name) = ?', row['policy'].downcase).first rescue nil
      if policy_id
        row[:policy_id] = policy_id
      end
      row.delete('policy')
    end
    if row['Assign Manager Role?'].present? && row['Assign Manager Role?'].casecmp("Yes") == 0
      row[:role_mapping_attributes] << {user_role_id: UserRole.manager_id}
    end
    if row['Assign Finance Manager Role?'].present? && row['Assign Finance Manager Role?'].casecmp("Yes") == 0
      row[:role_mapping_attributes] << {user_role_id: UserRole.finance_manager_id}
    end
    row
  end
end
