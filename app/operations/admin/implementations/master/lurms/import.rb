class Admin::Implementations::Master::Lurms::Import < Admin::Implementations::Processor::Import

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'lurms.import'
  headers ({
            :id => 'ID',
            :policy => 'Policy ID',
            :user_id => 'User Email / Mobile',
            :level_name => 'Level Name',
            :level_number => 'Level Number',
            :reviewer_email_mobile => 'Reviewer Email / Mobile',
            :min => "Minimum Threshold",
            :max => "Max Threshold",
            :destroy => 'Destroy'
  })

  attr_accessor :lurm_params, :provider, :application, :policy, :level
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
    lurm_params = set_params(data)
    if lurm_params[:policy_name].present?
      self.policy = get_policy(lurm_params[:policy_name], application)
    else
      self.policy = company.policies.default.first
    end
    if lurm_params[:user_email].present?
      entity_user_id = clean_up_data lurm_params[:user_email]
      entity_user = company.users.where(mobile_number: entity_user_id).or(company.users.where(email: entity_user_id)).first
    end
    unless entity_user.present?
      return result false,'User not found'
    end
    row_length = data.size
    lower_index = 2
    while(lower_index < row_length-1)
      level_name = data[lower_index+1].to_s
      level_number = data[lower_index+2].to_i
      reviewer_id = clean_up_data data[lower_index+3]
      min = data[lower_index+4].to_i
      max = (data[lower_index+5].present? ? data[lower_index+5].to_i : nil)
      if level_name.present? && level_number.present?
        self.level = get_level(level_name, level_number, provider)
        reviewer = company.users.where(mobile_number: reviewer_id).or(company.users.where(email: reviewer_id)).first
        mapping_exist = self.level.level_user_reviewer_mappings.where(policy_id: policy.id, reviewer_id: reviewer&.id, min: min, max: max, user_id: entity_user.id).first
        self.level.level_user_reviewer_mappings.create(reviewer_id: reviewer&.id, policy_id: policy.id,user_id: entity_user.id, min: min, max: max) unless mapping_exist.present?
        return result true, 'Reviewer Mapping created'
      end
      lower_index += 5
    end
    result true, 'Updated Successfully'
  end


  private

  def set_params(row)
    id = row[import_fields[:id]]
    policy_name = row[import_fields[:policy_name]].to_s
    user_email = row[import_fields[:user_email]]

    params = {
        id: id,
        policy_name: policy_name,
        user_email: user_email
    }
  end

  def import_fields
    {
        :id =>0,
        :policy_name => 1,
        :user_email => 2
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

  def clean_up_data(text)
    if text.is_a?(Float) || text.is_a?(Integer)
      text&.to_i&.to_s
    else
      text&.strip
    end
  end

end
