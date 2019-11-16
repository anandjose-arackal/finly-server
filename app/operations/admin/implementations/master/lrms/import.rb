class Admin::Implementations::Master::Lrms::Import < Admin::Implementations::Processor::Import

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'lrms.import'
  headers ({
      :id => 'ID',
      :policy => 'Policy Name',
      :policy_creation_flag => 'For New Policy Y / or Blank',
      :department_code => 'DepartmentCode',
      :location_code => 'LocationCode',
      :level_name => 'Level Name',
      :level_number => 'Level Number',
      :reviewer_email_mobile => 'Reviewer Email / Mobile / Employee ID',
      :with_exception => 'With Exception Y/N',
      :without_exception => 'Without Exception Y/N',
      :min => "Minimum Threshold",
      :max => "Max Threshold",
      :destroy => 'Destroy'
  })

  attr_accessor :lrm_params, :provider, :application, :policy, :level, :user_profiles
  def process
    self.user_profiles = UserProfile.joins(:user).where('users.company_id = ?', company.id)

    path = Rails.env.production? ? self.implementation_request.request_file&.url : self.implementation_request.request_file&.path
    self.input = Roo::Spreadsheet.open(path)
    output = {}
    custom_headers ={}
    input.each_with_pagename do |name, sheet|
      output[name] = []
      self.application = get_application(name)
      self.provider = name
      custom_headers[name] = sheet.row(1)
      (2..sheet.last_row).each do |i|
        row = sheet.row(i)
        begin
          result = process_row(row)
          unless result.is_a?(Admin::Implementations::Processor::Import::Result)
            item_complete false
            raise "invalid result"
          end
         rescue Exception => e
           result false, "#{e.message}"
         end

        unless result.success?
          item_complete false
          row << result.message
          failed = true
        end
        if result.success?
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
    result success: false, message: "Destroy action cant perform"
  end

  def update_record(data)
    result success: false, message: "Update action cant perform"
  end

  def create_record(data)
    lrm_params = set_params(data)
    if lrm_params[:policy_name].present?
      self.policy = get_policy(lrm_params[:policy_name], application)

      #IF policy with name not found and policy creation flag is seted system will create new policy
      if self.policy.blank? && lrm_params[:policy_creation_flag]
        self.policy = create_policy(lrm_params[:policy_name],application)
      elsif self.policy.blank? && !lrm_params[:policy_creation_flag]
        return result false, "Policy not found"
      end

    else
      self.policy = company.policies.default.first
    end

    if lrm_params[:department_code].present?
      department = company.departments.find_by department_code: lrm_params[:department_code]
      return result false, "Department not found with the department code" unless department.present?
      create_policy_dept_mapping(policy, department) if department.present?
    end

    if lrm_params[:location_code].present?
      location = company.locations.find_by location_code: lrm_params[:location_code]
      return result false, "Location not found with the location code" unless location.present?
      create_policy_location_mapping(policy, location)
    end
    row_length = data.size
    lower_index = 4
    while(lower_index < row_length-2)
      level_name = data[lower_index+1].to_s
      level_number = data[lower_index+2].to_i
      reviewer_id = clean_up_data data[lower_index+3].to_s
      min = data[lower_index+6].to_i
      max = (data[lower_index+7].present? ? data[lower_index+7].to_i : nil)
      if min.present? && max.present?
        if min >= max
          return result false, "Max Threshold should be greater than Min"
        end
      end
      exception = data[lower_index+4]&.to_s&.upcase == 'N' ? false : true
      wo_exception = data[lower_index+5]&.to_s&.upcase == 'N' ? false : true
      if level_name.present? && level_number.present? && level_number !=0
        self.level = get_level(level_name, level_number, provider)
        if reviewer_id.present?
          reviewer = get_reviewer(reviewer_id, application)
          unless  reviewer.present?
            return result false, "Reviewer Not Found"
          end
        else
          reviewer = nil
        end
        mapping_exist = self.level.level_reviewer_mappings.where( reviewer_id: reviewer&.id, min: min, max: max, exception: exception, wo_exception: wo_exception).first
        self.level.level_reviewer_mappings.create(reviewer_id: reviewer&.id, min: min, max: max, exception: exception, wo_exception: wo_exception) unless mapping_exist.present?
      else
        return  result false, 'Level Number and Name Cant be blank'
      end
      lower_index += 7
    end
    result true, 'Reviewer Mapping Created'
  end


  private

  def set_params(row)
    policy_name = row[import_fields[:policy_name]].to_s
    department_code = row[import_fields[:department_code]].to_s
    location_code = row[import_fields[:location_code]].to_s
    id = row[import_fields[:id]].to_s
    policy_creation_flag = row[import_fields[:policy_creation_flag ]]

    params = {
        id: id,
        policy_name: policy_name,
        policy_creation_flag: (policy_creation_flag.to_s.upcase == 'Y' ? true : false),
        department_code: department_code,
        location_code: location_code,
    }
  end

  def import_fields
    {
        :id => 0,
        :policy_name => 1,
        :policy_creation_flag => 2,
        :department_code => 3,
        :location_code => 4,
    }
  end


  def get_policy(policy_name,application)
    policy = self.company.policies.find_by(name: policy_name, application: application)
    return policy if policy.present?
    policy = self.company.policies.create(name: policy_name, application: application)
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

  def create_policy_dept_mapping(policy,department)
    return if policy.policy_department_mappings.where(department_id: department&.id).first&.present?
    policy.policy_department_mappings.create(department_id: department.id)
  end

  def create_policy_location_mapping(policy,location)
    return if policy.policy_location_mappings.where(location_id: location&.id).first&.present?
    policy.policy_location_mappings.create(location_id: location.id)
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
        "PoInvoiceProvider" =>"po_invoice_reviewer",
        "BankPaymentRequestProvider" =>"bank_payment_request_reviewer",
        "YesBankVendorProvider" =>"vendor_reviewer",
        "PaymentAgreementProvider" => "payment_agreement_reviewer"}

    user = get_user_entity(reviewer_id)
    if application == 'em' && user.present? && user&.roles&.pluck(:name)&.exclude?(role_provider_mapping[provider]&.to_sym)
      user.role_mapping.create(purpose_id: 1, user_role_id: UserRole.id_for(:manager))
    elsif application == 'vp' && user.present? && user.policy_user_roles.where(user_role_id: UserRole.id_for(role_provider_mapping[provider]&.to_sym), policy_id: self.policy.id).blank?
      user.policy_user_roles.create(policy_id: self.policy.id, user_role_id: UserRole.id_for(role_provider_mapping[provider]&.to_sym))
    end
    user
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
    user
  end

  def clean_up_data(text)
    if text.is_a?(Float) || text.is_a?(Integer)
      text&.to_i&.to_s
    else
      text&.to_s&.strip
    end
  end

end
