class ExportManager::Generator::Spreadsheet < ExportManager::Generator::Base

  module Builder
    extend ActiveSupport::Concern

    class_methods do
      def attribute(name, column_name: nil)
        column_name = name.to_s.humanize unless column_name.present?
        attributes << {name: name, column_name: column_name}
      end

      def attributes
        @attributes ||= []
      end
    end

  end

  def self.setup(master_class)
    master_class.include Builder
  end

  def perform
    headers = load_headers
    contents = load_contents
    exporter = Exporter::Spreadsheet.new(user, {headers: headers, contents: contents})
    file = Paperclip::Tempfile.new(file_name)
    open(file.path, 'wb') do |f|
      # case format
      # when :csv
      #   f.write exporter.generate_csv
      # when :xls
      f.write exporter.generate_xls
      # end
    end
    save_attachment(file)
    success!
  end

  # def format
  #   params[:export_format]&.to_sym
  # end

  def file_name
    # case format
    # when :xls
    return ['export', '.xls']
    # when :csv
    #   return ['export', '.csv']
    # else
    #   nil
    # end
  end

  def load_headers
    headers = []
    self.master.class.attributes.each do |attribute|
      headers << attribute[:column_name]
    end
    headers
  end

  def load_contents
    contents = []
    data = master.input
    return contents if data.nil?
    index = 1
    data.each do |entry|
      row = []
      self.master.class.attributes.each do |attribute|
        field = attribute[:name]
        if master.respond_to?(field)
          row << master.send(field, entry) rescue nil
        else
          raise "#{field} not defined for exporter #{master.class.name}"
        end
      end
      contents << row
      progress_update(index)
      index += 1
    end
    contents
  end

end