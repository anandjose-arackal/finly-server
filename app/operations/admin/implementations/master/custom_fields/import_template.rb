class Admin::Implementations::Master::CustomFields::ImportTemplates < Admin::Implementations::Processor::ImportTemplate

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'custom_fields.import_template'
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

  def valid_request
  end

  def input
    []
  end

  def post_process
  end

  def export(headers, contents)
    file = Tempfile.new(['custom_fields', '.xlsx'])
    workbook  = ::WriteXLSX.new(file)
    headers.each do |key, value|
      worksheet = workbook.add_worksheet(key)

      value.values.each_with_index do |item, index|
        worksheet.write( 0, index, item )
      end

    end
    workbook.close
    file.rewind

    temp_file = TemporaryFile.create file: file, expires_on: (DateTime.now.beginning_of_day + 1.day)
    temp_file.file.url
  end


end
