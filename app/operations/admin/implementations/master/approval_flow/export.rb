class Admin::Implementations::Master::ApprovalFlow::Export < Admin::Implementations::Processor::Export

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'approval_flow.export'
  has_scope :with_id

  #below headers not used in the core logic of this export
  #headings are dynamic in this export
  headers ({
      :policy => 'Policy Name',
      :user_id => 'User Email / Mobile',
      :level_name => 'Level Name',
      :level_number => 'Level Number',
      :reviewer_email_mobile => 'Reviewer Email / Mobile',
      :with_exception => 'With Exception Y/N',
      :without_exception => 'Without Exception Y/N',
      :min => "Minimum Threshold",
      :max => "Max Threshold"
  })

  attr_accessor :providers, :total_count, :headings

  def valid_request

  end

  def input
  end

  def process
    result_sheets = contents
    export(headings, result_sheets)
  end


  def contents
    contents = {}
    self.headings = {}
    providers = %w(
                    ReportProvider
                    MoneyRequestProvider
                    TravelRequestProvider
                    TravelRequestBookingProvider
                    PurchaseRequestProvider
                    PurchaseOrderProvider
                    NonPoInvoiceProvider
                    PoInvoiceProvider
                    BankPaymentRequestProvider
                    YesBankVendorProvider
                    PaymentAgreementProvider
                    BbpsBillerSubscriptionProvider
                    BbpsBillProvider
                    CreditNoteProvider)

    role_provider_mapping = {
        "PurchaseRequestProvider" =>"purchase_request_initiator",
        "PurchaseOrderProvider" =>"purchase_order_initiator",
        "NonPoInvoiceProvider" =>"non_po_invoice_initiator",
        "PoInvoiceProvider" => "po_invoice_initiator",
        "BankPaymentRequestProvider" =>"bank_payment_request_initiator",
        "YesBankVendorProvider" =>"vendor_creator",
        "PaymentAgreementProvider" => "payment_agreement_initiator",
        "BbpsBillerSubscriptionProvider" => "utility_bill_master_initiator",
        "BbpsBillProvider" => "utility_bill_initiator",
        "CreditNoteProvider" => "credit_note_initiator"}

    if params[:with_id] == 'all'
      params[:with_id] = company.policies.pluck(:id)
    end
    providers.each do |provider|
      total_count = 0
      contents[provider] = []
      self.headings[provider] = []
      result_hash = []
      policies = apply_scopes(company.policies)
      if %w(ReportProvider MoneyRequestProvider TravelRequestProvider TravelRequestBookingProvider).include?(provider)
        policies = policies.with_application(:em)
        policies.each do |policy|
          users = policy.users.includes(:profile)
          levels = policy.levels.non_deleted.where(associated_entity_type: provider).includes({level_user_reviewer_mappings: [reviewer: :profile]}, {level_reviewer_mappings: [reviewer: :profile]}).order(level_number: :asc)
          users.each do |emp|
            policy_details = {"Policy" => policy.name}
            policy_details["Employee ID"] = "#{emp.profile&.employee_id}"
            policy_details["Employee Name"] = "#{emp.name}"
            policy_details["Mobile No"] = "#{emp.mobile_number}"
            levels.each do |level|
              mappings = level.level_user_reviewer_mappings.where(user_id: emp.id)
              if mappings.empty?
                mappings = level.level_reviewer_mappings.non_deleted
              end
              reviewer_count = 1
              mappings.each do |mapping|
                key = "level #{level.level_number}_reviewer#{reviewer_count}"
                policy_details["#{key}employee_id"] = mapping.reviewer&.profile&.employee_id
                policy_details["#{key}name"] = mapping.reviewer&.name
                policy_details["#{key}mobile_number"] = mapping.reviewer&.mobile_number
                policy_details["#{key}email"] = mapping.reviewer&.email
                reviewer_count += 1
              end
            end
            result_hash << policy_details
          end
        end
      else
        policies = policies.with_application(:vp)
        policies.each do |policy|
          users = company.users.joins(:policy_user_roles).where(policy_user_roles:{policy_id: policy.id},policy_user_roles:{ user_role_id: UserRole.id_for(role_provider_mapping[provider].to_sym)})
          levels = policy.levels.non_deleted.where(associated_entity_type: provider).includes({level_user_reviewer_mappings: [reviewer: :profile]}, {level_reviewer_mappings: [reviewer: :profile]}).order(level_number: :asc)
          users.each do |emp|
            policy_details = {"Policy" => policy.name}
            policy_details["Employee ID"] = "#{emp.profile&.employee_id}"
            policy_details["Employee Name"] = "#{emp.name}"
            policy_details["Mobile No"] = "#{emp.mobile_number}"
            levels.each do |level|
              mappings = level.level_user_reviewer_mappings.where(user_id: emp.id)
              if mappings.empty?
                mappings = level.level_reviewer_mappings.non_deleted
              end
              reviewer_count = 1
              mappings.each do |mapping|
                key = "level #{level.level_number}_reviewer#{reviewer_count}"
                policy_details["#{key}employee_id"] = mapping.reviewer&.profile&.employee_id
                policy_details["#{key}name"] = mapping.reviewer&.name
                policy_details["#{key}mobile_number"] = mapping.reviewer&.mobile_number
                policy_details["#{key}email"] = mapping.reviewer&.email
                reviewer_count += 1
              end
            end
            result_hash << policy_details
          end
        end
      end
      all_header_key = result_hash.map {|hash| hash.keys}.flatten.uniq.sort
      all_header_key.map {|keys| self.headings[provider] << keys.humanize}
      contents[provider] = convert_hash_to_result_array(all_header_key, result_hash)
    end
    contents
  end

  def export(headers, contents)
    file = Tempfile.new(['effective_approval_export', '.xlsx'])
    workbook = ::WriteXLSX.new(file)
    contents.each do |name, sheet|
      worksheet = workbook.add_worksheet(name)
      headers[name].each_with_index do |item, index|
        worksheet.write(0, index, item)
      end
      sheet.each_with_index do |items, row|
        items.each_with_index do |item, column|
          worksheet.write(1 + row, column, item)
        end
      end
    end
    workbook.close
    file.rewind
    self.implementation_request.result_file = file
    self.implementation_request.save
    progress_update(:completed)
  end

  def convert_hash_to_result_array(headers_key, result_hash)
    data = []
    result_hash.each do |result|
      row = []
      headers_key.each do |key|
        row << (result[key].present? ? result[key] : '')
      end
      data << row
    end
    data
  end
end