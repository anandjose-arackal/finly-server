class PolicyUserRoles::Import < BaseOperation
  attr_accessor :file_url, :file, :result_hash, :params, :missing_params, :sheet, :header, :policy_user_params, :company, :policy

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters. please try again"
    end
  end

  def user_model
   [User, AdminUser]
  end

  def init
    self.company = Company.find_by_id params[:company_id].to_i
    self.file = params[:file]
    self.result_hash = {}
    if file.present?
      self.sheet = ImportUtil.open_spreadsheet(file)
      self.header = sheet.row(1)
    end
  end

  def validate
    if file.nil? || sheet.nil?
      add_message :error, "No file uploaded, please attach a file and try again"
    end
    if company.nil?
      add_message :error, "Company not found"
    end
  end

  def process
    user_roles = UserRole.all
    (2..sheet.last_row).each do |i|
     row = sheet.row(i)
     self.policy_user_params = process_row(row)
     self.policy = company.policies.find_by_id policy_user_params[:policy_id]
     unless policy.present?
      result_hash[i] = "Policy Not Found"
      next
     end

     entity_user_id = clean_up_data policy_user_params[:user_id]
     p  entity_user_id
     entity_user = company.users.where(mobile_number: entity_user_id).or(company.users.where(email: entity_user_id)).first
     unless entity_user.present?
       result_hash[i] = "User Not Found"
       next
     end

     policy_user_params[:roles].each do |k,v|
      role_id = user_roles.id_for(k)
      existing_mapping = policy.policy_user_roles.where(user_role_id: role_id, user_id: entity_user.id).first
      unless existing_mapping.present?
       role_mapping = policy.policy_user_roles.new(user_role_id: role_id, user_id: entity_user.id)
       if role_mapping.save
         result_hash[i] = "Success"
       else
         result_hash[i] = role_mapping.errors
       end
      end
     end
     end
  end

  def post_process
    self.file_url = create_response_csv
  end

  def success
    params[:file_url] = file_url
    PolicyUserRoles::Import::ResultPresenter.new(user, params, messages)
  end

  class PolicyUserRoles::Import::ResultPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :file_url

    def init
      self.file_url = params[:file_url]
    end
  end

  private

  def process_row(row)
    policy_id = row[import_fields[:policy_id]].to_i
    user_id = row[import_fields[:user_id]]

    params = {
      policy_id: policy_id,
      user_id: user_id,
      roles: {
        purchase_request_initiator: row[import_fields[:purchase_request_initiator]].to_s.upcase,
        purchase_request_reviewer: row[import_fields[:purchase_request_reviewer]].to_s.upcase,
        purchase_request_auditor: row[import_fields[:purchase_request_auditor]].to_s.upcase,
        purchase_order_initiator: row[import_fields[:purchase_order_initiator]].to_s.upcase,
        purchase_order_reviewer: row[import_fields[:purchase_order_reviewer]].to_s.upcase,
        purchase_order_auditor: row[import_fields[:purchase_request_auditor]].to_s.upcase,
        goods_receiver: row[import_fields[:goods_receiver]].to_s.upcase,
        invoice_initiator: row[import_fields[:invoice_initiator]].to_s.upcase,
        invoice_reviewer: row[import_fields[:invoice_reviewer]].to_s.upcase,
        invoice_auditor: row[import_fields[:invoice_auditor]].to_s.upcase,
        payment_ticket_initiator: row[import_fields[:payment_ticket_initiator]].to_s.upcase,
        payment_ticket_viewer: row[import_fields[:payment_ticket_viewer]].to_s.upcase,
        payment_ticket_creditor: row[import_fields[:payment_ticket_creditor]].to_s.upcase,
        payment_ticket_auditor: row[import_fields[:payment_ticket_auditor]].to_s.upcase,
        item_master_manager: row[import_fields[:item_master_manager]].to_s.upcase,
        inventory_manager: row[import_fields[:inventory_manager]].to_s.upcase,
        vendor_creator: row[import_fields[:vendor_creator]].to_s.upcase,
        vendor_reviewer: row[import_fields[:vendor_reviewer]].to_s.upcase,
        vendor_auditor: row[import_fields[:vendor_auditor]].to_s.upcase
      }
    }
  end

  def import_fields
    {
       :policy_id => 0,
       :user_id => 1,
       :purchase_request_initiator => 2,
       :purchase_request_reviewer => 3,
       :purchase_request_auditor => 4,
       :purchase_order_initiator => 5,
       :purchase_order_reviewer => 6,
       :purchase_order_auditor => 7,
       :goods_receiver => 8,
       :invoice_initiator => 9,
       :invoice_reviewer => 10,
       :invoice_auditor => 11,
       :payment_ticket_initiator => 12,
       :payment_ticket_viewer => 13,
       :payment_ticket_creditor => 14,
       :payment_ticket_auditor => 15,
       :item_master_manager => 16,
       :inventory_manager => 17,
       :vendor_creator => 18,
       :vendor_reviewer => 19,
       :vendor_auditor => 20
    }
  end

  def create_response_csv
    file = Tempfile.new("bulk_import_policy_user_mapping.csv")
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

   def clean_up_data(text)
     if text.is_a?(Float) || text.is_a?(Integer)
       text.to_i
     else
       text.strip
     end
   end
end