class ExportManager::Template::Processors::XlsProcessor < ExportManager::Template::Processor
  def generate(template, iter_field, data, file_name)
    header = ExportManager::Builders::Spreadsheet::Header.new
    template['columns'].each do |column|
      header.add column['label']
    end

    file = Paperclip::Tempfile.new(file_name)
    workbook = ::WriteXLSX.new(file, strings_to_urls: false)
    worksheet = workbook.add_worksheet('Sheet 1')
    record_index = 1
    row_index = 1
    data.find_each do |record|
      self.current_record = record
      exposure = record.to_exposure

      if iter_field.present? and exposure.send(iter_field["field"]).present?
        exposure.send(iter_field["field"]).each do |iter_record|
          row = ExportManager::Builders::Spreadsheet::Row.new(record: record, header: header)
          template['columns'].each do |column|
            value = LiquidHelper.interpolate(column['value'], { "record" => exposure, "#{iter_field["template_prefix"]}" => iter_record })
            row.add column['label'], value
          end
          add_row_to_sheet(worksheet, row, row_index)
          row_index += 1
        end
      else
        row = ExportManager::Builders::Spreadsheet::Row.new(record: record, header: header)
        template['columns'].each do |column|
          value = exposure.template(column['value'])
          row.add column['label'], value
        end
        add_row_to_sheet(worksheet, row, row_index)
        row_index += 1
      end


      progress_update(record_index, force_update: false)
      record_index += 1
    end
    # Force update the final count
    progress_update(record_index - 1, force_update: true)

    header.list.each_with_index do |item, header_index|
      worksheet.write(0, header_index, item)
    end
    workbook.close

    file.rewind
    file
  end

  def add_row_to_sheet(worksheet, row, row_index)
    row.build.each_with_index do |item, column|
      # #TO DO START
      #  WriteXLSX have different method to write date, string, number, curreny and blank
      #  using these method will help to xls file processing more fastly
      #  need to introdue column format type in export template to indtroduece these methods

      #  eg:write_string
      #     write_number
      #     workbook.add_format({:num_format => 'dd-mm-yyyy'})
      #     write_date_time
      # #TO DO END

      worksheet.write_string(row_index, column, item)
      #worksheet.write(record_index, column, item)
    end
  end
end
