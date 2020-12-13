class ExportManager::Template::Processors::CSVProcessor < ExportManager::Template::Processor
  def generate(template, data, file_name)
    file = Paperclip::Tempfile.new(file_name)
    CSV.open(file.path, 'w') do |csv|
      csv << template['columns'].map do |column|
        column['label']
      end

      index = 1
      data.find_each do |record|
        self.current_record = record

        exposure = record.to_exposure
        csv << template['columns'].map do |column|
          exposure.template(column['value'])
        end
        progress_update(index, force_update: false)

        index += 1
      end

      # Force update the final count
      progress_update(index - 1, force_update: true)
    end

    file.rewind
    file
  end
end
