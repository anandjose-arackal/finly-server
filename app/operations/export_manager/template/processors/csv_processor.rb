class ExportManager::Template::Processors::CSVProcessor < ExportManager::Template::Processor
  def generate(template, data, file_name, include_custom_fields)
    file = Paperclip::Tempfile.new(file_name)
    CSV.open(file.path, 'w') do |csv|
      header = ExportManager::Builders::Spreadsheet::Header.new
      template['columns'].each do |column|
        header.add column['label']
      end
      csv << header.list  # TODO: headers should not be added here as we wont get custom fields headers
      index = 1
      data.find_each do |record|
        update record: record
        row = ExportManager::Builders::Spreadsheet::Row.new(record: record, header: header)
        exposure = record.to_exposure
        template['columns'].each do |column|
          value = exposure.template(column['value'])
          row.add column['label'], value.present? ? value : ''
        end

        if include_custom_fields
          exposure.custom_fields.each do |cf|
            row.add cf[:name], cf[:value].present? ? cf[:value] : ''
          end
        end

        csv << row.build.map do |item|
          item.present? ? item : ''
        end

        progress_update(index)
        index += 1
      end

      # TODO: following is not working to replace the header as it is writing over existing data, it is removing content from next rows. Find a way to add custom_fields headers
      # csv.rewind
      # csv << header.list
    end

    file.rewind
    file
  end
end
