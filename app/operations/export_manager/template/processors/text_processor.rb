class ExportManager::Template::Processors::TextProcessor < ExportManager::Template::Processor
  def generate(template, data, file_name)
    file_data = Liquid::Template.parse(template).render('records' => data.to_exposures)
    file = Paperclip::Tempfile.new(file_name)
    open(file.path, 'wb') { |f| f.write file_data }
    progress_update(data.count)

    file.rewind
    file
  end
end
