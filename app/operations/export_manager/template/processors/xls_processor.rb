class ExportManager::Template::Processors::XlsProcessor < ExportManager::Template::Processor

  def generate(template, data, file_name)
    header = ExportManager::Builders::Spreadsheet::Header.new
    template[:columns].each do |column|
      header.add column[:label]
    end

    file = Paperclip::Tempfile.new(file_name)
    workbook = ::WriteXLSX.new(file, strings_to_urls: false)
    worksheet = workbook.add_worksheet('Sheet 1')
    index = 1
    data.find_each do |record|
      update record: record
      row = ExportManager::Builders::Spreadsheet::Row.new(record: record, header: header)
      exposure = record.to_exposure
      template[:columns].each do |column|
        value = exposure.template(column[:value])
        row.add column[:label], value
      end
      row.build.each_with_index do |item, column|
        worksheet.write(index, column, item)
      end

      progress_update(index)
      index += 1
    end
    header.list.each_with_index do |item, index|
      worksheet.write(0, index, item)
    end
    workbook.close

    file.rewind
    file
  end

end