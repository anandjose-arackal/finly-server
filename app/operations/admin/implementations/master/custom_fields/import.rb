class Admin::Implementations::Master::CustomFields::Import < Admin::Implementations::Processor::Import

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'custom_fields.import'
  headers({
              "Field Configuration" => {
                  :id => "ID",
                  :field_name => "Field Name",
                  :field_type => "Field Type",
                  :parent_mapping => "Associated with",
                  :mandatory => "Mandatory Y / N",
                  :global => "Global Y / N",
                  :root => 'Root Field',
                  :field_key => 'Field Key'
              },
              "Drop Down Data" => {
                  :field_name_1 => "Field Name",
                  :dependent_1 => "Is Related to Next Column (Y/N)",
                  :field_name_2 => "Field Name",
                  :dependent_2 => "Is Related to Next Column",
                  :field_name_3 => "Field Name",
                  :dependent_3 => "Is Related to Next Column"
              },
              "Configurations" =>{
                  :field_type => "Field Type",
                  :value => "Value",
                  :parent => "Associated With",
                  :parent_value => "Value"
              }
          })

  attr_accessor :field_configuration_params, :drop_down_items
  def process
    self.drop_down_items = []
    path = Rails.env.production? ? self.implementation_request.request_file&.url : self.implementation_request.request_file&.path
    self.input = Roo::Spreadsheet.open(path)
    output = {}
    output['Field Configuration'] = []
    sheet = input.sheet(0)
    (2..sheet.last_row).each do |i|
        row = sheet.row(i)
        #begin
          result = process_row(row)
          unless result.is_a?(Admin::Implementations::Processor::Import::Result)
            item_complete false
            raise "invalid result"
          end
        # rescue Exception => e
        #   result false, "#{e.message}"
        # end

        unless result.success?
          item_complete false
          row << result.message
          failed = true
        end
        if result.success?
          row << result.message
          item_complete true
        end
        output['Field Configuration'] << row
    end
    unless drop_down_items.blank?
      set_drop_down_items
    end
    export headers, output
  end

  def export(headers, contents)
    file = Tempfile.new(['custom_field_result', '.xlsx'])
    workbook  = ::WriteXLSX.new(file)
    contents.each  do |name, sheet|
      worksheet = workbook.add_worksheet(name)
      headers[name]&.values.each_with_index do |item, index|
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
    create_record(data)
  end

  def destroy_records(data)
    result success: false, message: "Destroy action cant perform"
  end

  def update_record(data)
    result success: false, message: "Update action cant perform"
  end

  def create_record(data)
    messages, field_configuration_params =set_params(data)
    custom_field = company.field_configurations.non_deleted.where(field_name: field_configuration_params[:field_name],
                                                      field_type_id: field_configuration_params[:field_type_id],
                                                      configurable_type: field_configuration_params[:configurable_type],
                                                      configurable_id: field_configuration_params[:configurable_id]).first
    unless custom_field.present?
      custom_field = FieldConfiguration.new (field_configuration_params)
      unless custom_field.save
        result false, custom_field.errors
      else
        if custom_field.field_type_id == 5
          self.drop_down_items << {id: custom_field.id, field_name: custom_field.field_name}
        end
      end
    else
      if custom_field.field_type_id == 5
        self.drop_down_items << {id: custom_field.id, field_name: custom_field.field_name}
      end
    end

    result true, 'Field Configuration Created'
  end


  private

  def set_params(row)
    messages = []
    id = row[import_fields[:id]]
    field_name = row[import_fields[:field_name]]
    field_type = row[import_fields[:field_type]].to_i
    mandatory = row[import_fields[:mandatory]].to_s&.upcase == 'Y' ? true : false
    parent_mapping = row[import_fields[:parent_mapping]]
    root = row[import_fields[:root]].to_s&.upcase == 'Y' ? true : false
    if parent_mapping.is_a?(String)
      parent_mapping= parent_mapping.split(',')
    else
      parent_mapping = [parent_mapping]
    end
    global = row[import_fields[:global]]
    configurable_type = [1,2,15,16].include?(parent_mapping.first&.to_i) ?  'Policy' : 'Company'
    configurable_id = configurable_type == 'Company' ? company.id : nil
    if configurable_type == 'Policy'
      policy_field_mappings_attributes =[]
      company.policies.each do |policy|
        policy_field_mappings_attributes << {policy_id: policy.id}
      end
      configurable_type_id = nil
    end

    field_parent_mappings_attributes =[]
    if parent_mapping.present?
      parent_mapping.each do |mapping_id|
        field_parent_mappings_attributes << {"field_parent_type_id"=> mapping_id.to_s}
      end
    end
    if field_type != FieldType.id_for(:text)
      drop_down_items_attributes =[{"name"=>"Test"}]
    end

    params = {
             field_name: field_name,
             mandatory: mandatory,
             global: global,
             field_type_id: field_type,
             configurable_type: configurable_type,
             configurable_id: configurable_id,
             company_id: company.id,
             root_field: root
        }
    params[:field_parent_mappings_attributes] = field_parent_mappings_attributes
    if field_type != FieldType.id_for(:text)
      params[:drop_down_items_attributes] = drop_down_items_attributes
    end
    if policy_field_mappings_attributes.present?
      params[:policy_field_mappings_attributes] = policy_field_mappings_attributes
    end
    [messages,params]
  end

  def import_fields
      {
          :id => 0,
          :field_name => 1,
          :field_type => 2,
          :parent_mapping => 3,
          :mandatory => 4,
          :global => 5,
          :root => 6,
          :field_key => 7
      }
  end


  def set_drop_down_items
    sheet = input.sheet(1)
    drop_down_names = input.sheet(1).row(2)
    (3..sheet.last_row).each do |i|
      row = sheet.row(i)
      lower_limit = 0
      size= row.size
      ddi = nil
      previous_field = nil
      drop_down_count = 0
      while(lower_limit < size)
        field_name = drop_down_items[drop_down_count][:field_name]
        dependable = row[lower_limit+1].to_s == 'Y' ? true : false
        if ddi.present?
          field_configuration = ddi.dependent_field_configurations.where(field_name: field_name).first
        else
          field_configuration = FieldConfiguration.non_deleted.find drop_down_items[drop_down_count][:id]
        end
        if field_configuration.present?
          unless field_configuration.drop_down_items.pluck(:name).include?(row[lower_limit])
            ddi = field_configuration.drop_down_items.create(name: row[lower_limit])
            previous_field = field_configuration
          else
            ddi = field_configuration.drop_down_items.where(name: row[lower_limit]).first
            previous_field = field_configuration
          end
          drop_down_count += 1
          lower_limit += 2
          next
        end

        unless field_configuration.present? && dependable && ddi.blank?
         field_configuration = take_a_copy(previous_field, field_name,row[lower_limit])
         field_configuration.parent_dependent_field_configuration_mappings.build(parent: ddi).save
         ddi = field_configuration.drop_down_items.first
         previous_field = field_configuration
        end
        drop_down_count += 1
        lower_limit += 2
      end

    end
  end

  def take_a_copy(previous_field,field_name,item_value)
    field_params = { enabled: true,
                    field_type_id: previous_field.field_type_id,
                    configurable_type: previous_field.configurable_type,
                    configurable_id: previous_field.configurable_id,
                    company: company,
                    field_name: field_name,
                    drop_down_items_attributes: [{name: item_value }],
                    root_field: false}
    field_parent_mappings_attributes = []
    previous_field.field_parent_mappings.each do |field_parent_mapping|
        field_parent_mappings_attributes << {"field_parent_type_id"=> field_parent_mapping.field_parent_type_id&.to_s}
    end
    policy_field_mappings_attributes = []
    previous_field.policy_field_mappings.each do |policy_field_mapping|
      policy_field_mappings_attributes << {policy_id: policy_field_mapping.policy_id}
    end
    if field_parent_mappings_attributes.present?
        field_params[:field_parent_mappings_attributes]= field_parent_mappings_attributes
    end

    if policy_field_mappings_attributes.present?
      field_params[:policy_field_mappings_attributes] = policy_field_mappings_attributes
    end
    duplicate_field_configuration = FieldConfiguration.new field_params
    duplicate_field_configuration.save
    duplicate_field_configuration
  end

end
