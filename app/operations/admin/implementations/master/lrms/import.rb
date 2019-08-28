class Admin::Implementations::Master::Lrms::Import < Admin::Implementations::Processor::Import

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'lrms.import'
  headers ({
            :id => 'ID',
            :policy => 'Policy ID',
            :department_code => 'DepartmentCode',
            :location_code => 'LocationCode',
            :level_name => 'Level Name',
            :level_number => 'Level Number',
            :reviewer_email_mobile => 'Reviewer Email / Mobile',
            :min => "Minimum Threshold",
            :max => "Max Threshold",
            :destroy => 'Destroy'
  })

  attr_accessor :lrm_params, :provider, :application, :policy, :level
  def process
    self.input = Roo::Spreadsheet.open(self.implementation_request.request_file.url)
    output = {}
    input.each_with_pagename do |name, sheet|
      output[name] = []
      self.application = get_application(name)
      self.provider = name
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
      export headers.values, output
    end

  end

  def export(headers, contents)
    file = Tempfile.new(['lrm_import_result', '.xlsx'])
    workbook  = ::WriteXLSX.new(file)
    contents.each  do |name, sheet|
      worksheet = workbook.add_worksheet(name)

      headers.each_with_index do |item, index|
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
    else
      self.policy = company.policies.default.first
    end
    if lrm_params[:department_code].present?
      department = company.departments.find_by department_code: lrm_params[:department_code]
      create_policy_dept_mapping(policy, department) if department.present?
    end

    if lrm_params[:location_code].present?
      location = company.locations.find_by location_code: lrm_params[:location_code]
      create_policy_location_mapping(policy, location)
    end
    row_length = data.size
    lower_index = 3
    while(lower_index < row_length-1)
      level_name = data[lower_index+1].to_s
      level_number = data[lower_index+2].to_i
      reviewer_id = clean_up_data data[lower_index+3].to_s
      min = data[lower_index+4].to_i
      max = (data[lower_index+5].present? ? data[lower_index+5].to_i : nil)
      if level_name.present? && level_number.present? && reviewer_id.present?
        self.level = get_level(level_name, level_number, provider)
        reviewer = company.users.where(mobile_number: reviewer_id).or(company.users.where(email: reviewer_id)).first
        if reviewer
          if reviewer.policies.pluck(:id).exclude?(policy.id)
            self.policy.user_mapping.create(user: reviewer)
          end
          mapping_exist = self.level.level_reviewer_mappings.where( reviewer_id: reviewer.id, min: min, max: max).first
          self.level.level_reviewer_mappings.create(reviewer_id: reviewer.id, min: min, max: max) unless mapping_exist.present?
          return result true, 'Reviewer Mapping Created'
        else
          return result false, 'Reviewer not found'
        end
      end
      lower_index += 5
    end
    result true, 'Updated Successfully'
  end


  private

  def set_params(row)
    p row
    policy_name = row[import_fields[:policy_name]].to_s
    department_code = row[import_fields[:department_code]].to_s
    location_code = row[import_fields[:location_code]].to_s
    id = row[import_fields[:id]].to_s

    params = {
        id: id,
        policy_name: policy_name,
        department_code: department_code,
        location_code: location_code,
    }
  end

  def import_fields
    {
        :id => 0,
        :policy_name => 1,
        :department_code => 2,
        :location_code => 3,
    }
  end


  def get_policy(policy_name,application)
    policy = self.company.policies.find_by(name: policy_name, application: application)
    return policy if policy.present?
    policy = self.company.policies.create(name: policy_name, application: application)
  end

  def get_level(level_name, level_number,provider)
    level =  self.policy.levels.non_deleted.where(level_number: level_number, associated_entity_type: provider).first
    return level if level.present?
    level = self.policy.levels.create(name: level_name, level_number: level_number, associated_entity_type: provider)
  end

  def get_application(name)
    %w(ReportProvider MoneyRequestProvider TravelRequestProvider).include?(name) ? 'em' : 'vp'
  end

  def create_policy_dept_mapping(policy,department)
    return if policy.policy_department_mappings.where(department.id).first.present?
    policy.policy_department_mappings.create(department_id: department.id)
  end

  def create_policy_location_mapping(policy,location)
    return if policy.policy_location_mappings.where(location.id).first.present?
    policy.policy_location_mappings.create(location_id: location.id)
  end


  def clean_up_data(text)
    if text.is_a?(Float) || text.is_a?(Integer)
      text.to_i.to_s
    else
      text.strip
    end
  end

end
