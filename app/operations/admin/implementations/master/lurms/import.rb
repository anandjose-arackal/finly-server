class Admin::Implementations::Master::Lurms::Import < Admin::Implementations::Processor::Import

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'lurms.import'
  headers ({
      :id => 'ID',
      :policy => 'Policy Name',
      :policy_creation_flag => 'For New Policy Y / or Blank',
      :user_id => 'User Email / Mobile / Employee ID',
      :level_name => 'Level Name',
      :level_number => 'Level Number',
      :reviewer_email_mobile => 'Reviewer Email / Mobile / Employee ID',
      :with_exception => 'With Exception Y/N',
      :without_exception => 'Without Exception Y/N',
      :min => "Minimum Threshold",
      :max => "Max Threshold",
      :destroy => 'Destroy'
  })

  attr_accessor :lurm_params, :provider, :application, :policy, :level, :user_profiles
  def process
    self.user_profiles = UserProfile.joins(:user).where('users.company_id = ?', company.id)
    path = Rails.env.production? ? self.implementation_request.request_file&.url : self.implementation_request.request_file&.path
    self.input = Roo::Spreadsheet.open(path)
    output = {}
    custom_headers = {}
    input.each_with_pagename do |name, sheet|
      output[name] = []
      self.application = get_application(name)
      self.provider = name
      custom_headers[name] = sheet.row(1)
      (2..sheet.last_row).each do |i|
        row = sheet.row(i)
        #begin
          result = process_row(row)
          unless result.is_a?(Admin::Implementations::Processor::Import::Result)
            item_complete false
            #raise "invalid result"
          end
        #rescue Exception => e
           #result false, ""
        #end

        unless result&.success?
          item_complete false
          row << result.message
          failed = true
        end
        if result&.success?
          row << result.message
          item_complete true
        end
        output[name] << row
      end
    end
    export custom_headers, output
  end

  def export(headers, contents)
    file = Tempfile.new(['lrm_import_result', '.xlsx'])
    workbook  = ::WriteXLSX.new(file)
    contents.each  do |name, sheet|
      worksheet = workbook.add_worksheet(name)

      headers[name].each_with_index do |item, index|
        worksheet.write( 0, index, item )
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

  def process_row(data)
    id = data[0]
    destroy_action = data.last
    if destroy_action&.to_s&.downcase == 'y'
      destroy_records(data)
    elsif id.present?
      update_record(data)
    else
      create_record(data)
    end
  end

  def destroy_records(data)
    lurm_params = set_params(data)
    lurm = LevelUserReviewerMapping.find_by id: lurm_params[:id]
    unless lurm.present?
      return result  false,"Mapping not found"
    else
      if lurm.destroy
        return result  true,"Level Reviewer Mapping Destroyed"
      end
    end
  end

  def update_record(data)
    lurm_params = set_params(data)
    lurm = LevelUserReviewerMapping.find_by id: lurm_params[:id]
    unless lurm.present?
      return result  false, message: "Mapping not found"
    end
    self.policy = lurm.policy

    if lurm_params[:min].present? && lurm_params[:max].present?
      if lurm_params[:min] >= lurm_params[:max]
        return result false, "Max Threshold should be greater than Min"
      end
    end

    if lurm_params[:reviewer_email].present?
      reviewer_email = clean_up_data lurm_params[:reviewer_email]
      reviewer = get_reviewer(reviewer_email, application)&.id
      unless  reviewer.present?
        return result false, "Reviewer Not Found"
      end
    else
      reviewer = nil
    end
    lurm_params[:reviewer_id] = reviewer

    unless lurm.update(lurm_params.except(:reviewer_email,:policy_name,:policy_creation_flag,:user_email))
      return result false, lurm.errors.full_messages
    end
    result true, 'Updated Successfully'
  end

  def create_record(data)
    lurm_params = set_params(data)
    # Find or Create a policy for MAP
    if lurm_params[:policy_name].present?
      self.policy = get_policy(lurm_params[:policy_name], application)

      #IF policy with name not found and policy creation flag is seted system will create new policy
      if self.policy.blank? && lurm_params[:policy_creation_flag]
        self.policy = create_policy(lurm_params[:policy_name],application)
      elsif self.policy.blank? && !lurm_params[:policy_creation_flag]
        return result false, "Policy not found"
      end

    else
      self.policy = company.policies.default.first
    end

    # Find the user to map
    if lurm_params[:user_email].present?
      entity_user_id = clean_up_data lurm_params[:user_email]
      entity_user = get_user_entity(entity_user_id)
    end

    unless entity_user.present?
      return result false,'User not found'
    end

    assign_initiator_role(entity_user)

    #Check and add user to the policy if expense management
    check_part_of_policy(entity_user) if self.application == 'em'
    row_length = data.size
    lower_index = 3
    while(lower_index < row_length-1)
      level_name = data[lower_index+1].to_s
      level_number = data[lower_index+2].to_i
      reviewer_id = clean_up_data data[lower_index+3]
      min = data[lower_index+6].to_i
      max = (data[lower_index+7].present? ? data[lower_index+7].to_i : nil)
      if min.present? && max.present?
        if min >= max
          return result false, "Max Threshold should be greater than Min"
        end
      end
      exception = data[lower_index+4]&.to_s&.upcase == 'N' ? false : true
      wo_exception = data[lower_index+5]&.to_s&.upcase == 'N' ? false : true

      if level_name.present? && level_number.present? && level_number != 0
        self.level = get_level(level_name, level_number, provider)
        if reviewer_id.present?
          reviewer = get_reviewer(reviewer_id, application)
          unless  reviewer.present?
            return result false, "Reviewer Not Found"
          end
        else
          reviewer = nil
        end
        mapping_exist = self.level.level_user_reviewer_mappings.where(policy_id: policy.id, reviewer_id: reviewer&.id, min: min, max: max, user_id: entity_user.id, exception: exception, wo_exception: wo_exception ).first
        self.level.level_user_reviewer_mappings.create(reviewer_id: reviewer&.id, policy_id: policy.id,user_id: entity_user.id, min: min, max: max, exception: exception, wo_exception: wo_exception) unless mapping_exist.present?
      end
      lower_index += 7
    end
    result true, 'Reviewer Mapping Created'
  end


  private

  def set_params(row)
    id = row[import_fields[:id]]
    policy_name = row[import_fields[:policy_name]].to_s
    user_email = row[import_fields[:user_email]]
    policy_creation_flag = row[import_fields[:policy_creation_flag]]
    reviewer_email = row[import_fields[:reviewer_email]]
    exception = row[import_fields[:exception]]&.to_s&.upcase == 'N' ? false : true
    wo_exception = row[import_fields[:wo_exception]]&.to_s&.upcase == 'N' ? false : true
    min = row[import_fields[:min]]
    max = row[import_fields[:max]]

    params = {
        id: id,
        policy_name: policy_name,
        policy_creation_flag: (policy_creation_flag.to_s.upcase == 'Y' ? true : false),
        user_email: user_email,
        reviewer_email: reviewer_email,
        exception: exception,
        wo_exception: wo_exception,
        min: (min.present? ? min.to_i : 0),
        max: (max.present? ? max.to_i : nil)
    }
  end

  def import_fields
    {
        :id => 0,
        :policy_name => 1,
        :policy_creation_flag => 2,
        :user_email => 3,
        :reviewer_email => 6,
        :exception => 7,
        :wo_exception => 8,
        :min => 9,
        :max => 10
    }
  end


  def get_policy(policy_name,application)
    policy = self.company.policies.find_by(name: policy_name, application: application)
  end

  def create_policy(policy_name, application)
    policy = self.company.policies.create(name: policy_name, application: application)
  end

  def check_part_of_policy(entity_user)
    mapping = self.policy.user_mapping.find_by(user_id: entity_user.id)
    unless mapping.present?
      self.policy.user_mapping.create(user_id: entity_user.id)
    end
  end

  def get_reviewer(reviewer_id, application)
    role_provider_mapping = {
        "ReportProvider" => "manager",
        "MoneyRequestProvider" => "manager",
        "TravelRequestProvider" => "manager",
        "TravelRequestBookingProvider" => "manager",
        "PurchaseRequestProvider" =>"purchase_request_reviewer",
        "PurchaseOrderProvider" =>"purchase_order_reviewer",
        "NonPoInvoiceProvider" =>"non_po_invoice_reviewer",
        "PoInvoiceProvider" => "po_invoice_reviewer",
        "BankPaymentRequestProvider" =>"bank_payment_request_reviewer",
        "YesBankVendorProvider" =>"vendor_reviewer",
        "PaymentAgreementProvider" => "payment_agreement_reviewer",
        "BbpsBillerSubscriptionProvider" => "utility_bill_master_reviewer",
        "BbpsBillProvider" => "utility_bill_reviewer",
        "CreditNoteProvider"=> "credit_note_reviewer"}

    entity_user = get_user_entity(reviewer_id)
    if application == 'em' && entity_user.present? && entity_user&.roles&.pluck(:name)&.exclude?(role_provider_mapping[provider]&.to_sym)
      entity_user.role_mapping.create(purpose_id: 1, user_role_id: UserRole.id_for(:manager))
    elsif application == 'vp' && entity_user.present? && entity_user.policy_user_roles.where(user_role_id: UserRole.id_for(role_provider_mapping[provider]&.to_sym), policy_id: self.policy.id).first.nil?
      entity_user.policy_user_roles.create(policy_id: self.policy.id, user_role_id: UserRole.id_for(role_provider_mapping[provider]&.to_sym))
    end
    entity_user
  end

  def get_level(level_name, level_number,provider)
    level =  self.policy.levels.non_deleted.where(level_number: level_number, associated_entity_type: provider).first
    update_level_name(level_name, level)
    return level if level.present?
    level = self.policy.levels.create(name: level_name, level_number: level_number, associated_entity_type: provider)
  end

  def update_level_name(level_name=nil, level=nil)
    if level.present? && level_name.present? && (level.name != level_name)
      level.update(name: level_name)
    end
  end

  def get_application(name)
    %w(ReportProvider MoneyRequestProvider TravelRequestProvider TravelRequestBookingProvider).include?(name) ? 'em' : 'vp'
  end

  def get_user_entity(identifier)
    user = nil
    if Constants::VALID_EMAIL_FORMAT.match?(identifier)
      user = company.users.find_by_email identifier
    elsif Constants::VALID_MOBILE_NUMBER.match?(identifier)
      user = company.users.find_by_mobile_number identifier
    else
      user = self.user_profiles.where('user_profiles.employee_id = ?', identifier&.to_s)&.last&.user
    end
    check_enable_feature_subscription(user) unless user.nil?
    user
  end

  def check_enable_feature_subscription(user)
    if self.application == 'em'
      return true if user&.user_panel_subscription&.expense_management?
      #enabling EM module for the user
      user.user_panel_subscription.update(expense_management: true)
      role_mapping = user.role_mapping.expense_management.employee
      if role_mapping.blank?
        user.role_mapping.create(user_role_id: UserRole.id_for(:employee), purpose_id: 1)
      end
    elsif self.application == 'vp'
      return true if user&.user_panel_subscription&.yes_bank_account_transfer?
      #enabling VP module for the user
      user.user_panel_subscription.update(yes_bank_account_transfer: true)
      role_mapping = user.role_mapping.expense_management.employee
      if role_mapping.blank?
        user.role_mapping.create(user_role_id: UserRole.id_for(:employee), purpose_id: 2)
      end
    end
  end

  def assign_initiator_role(entity_user)
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
        "CreditNoteProvider"=> "credit_note_initiator"}

    if application == 'em' && entity_user.present? && policy.user_mapping.where(user_id: entity_user.id).first&.nil?
      policy.user_mapping.create(user_id: entity_user.id)
    elsif application == 'vp' && entity_user.present? && entity_user.policy_user_roles.where(user_role_id: UserRole.id_for(role_provider_mapping[provider]&.to_sym), policy_id: self.policy.id).first.nil?
      entity_user.policy_user_roles.create(policy_id: self.policy.id, user_role_id: UserRole.id_for(role_provider_mapping[provider]&.to_sym))
    end
  end

  def clean_up_data(text)
    if text.is_a?(Float) || text.is_a?(Integer)
      text&.to_i&.to_s
    else
      text&.to_s&.strip
    end
  end

end
