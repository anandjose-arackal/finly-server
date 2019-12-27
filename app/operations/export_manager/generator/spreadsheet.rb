class ExportManager::Generator::Spreadsheet < ExportManager::Generator::Base

  class Attribute
    attr_accessor :name, :column_name, :dynamic

    def initialize(name:, column_name: nil, dynamic: false)
      self.name = name
      self.column_name = column_name || name.to_s.humanize
      self.dynamic = dynamic
    end

  end

  class Header

    def list
      @list ||= []
    end

    def add(name)
      list << name unless list.include?(name)
    end

    # def index_of(name)
    #   headers << name unless headers.include?(name)
    #
    #   headers.find_index(name)
    # end

  end

  class Row
    attr_accessor :record, :header

    def initialize(record:, header:)
      self.record = record
      self.header = header
    end

    def values
      @values ||= {}
    end

    def add(column, value)
      header.add column
      values[column] = value
    end

    def build
      data = []
      header.list.each do |column|
        data << values[column]
      end
      data
    end

  end

  class Builder
    attr_accessor :master, :processor, :header

    def initialize(processor)
      self.processor = processor
      self.master = processor.master
      self.header = Header.new
    end

    def build
      generate_rows
      file = generate_spreadsheet
      self.processor.save_attachment file
      self.processor.success!
      file
    end

    def generate_rows
      return unless master.input.present?

      index = 1
      master.input.each do |record|
        row = Row.new(record: record, header: header)
        master.class.attributes.each do |attribute|
          if attribute.dynamic
            master.send attribute.name, row, record
          else
            value = master.send attribute.name, record rescue nil
            row.add attribute.column_name, value
          end
        end
        rows << row

        self.processor.progress_update(index)
        index += 1
      end
    end

    def generate_spreadsheet
      headers = header.list
      contents = []
      self.rows.each do |row|
        contents << row.build
      end
      exporter = Exporter::Spreadsheet.new(self.processor.user, {headers: headers, contents: contents})
      file_name = ['export', '.xls']
      file = Paperclip::Tempfile.new(file_name)
      open(file.path, 'wb') do |f|
        # case format
        # when :csv
        #   f.write exporter.generate_csv
        # when :xls
        f.write exporter.generate_xls
        # end
      end
      file
    end

    def rows
      @rows ||= []
    end

  end

  module Helper
    extend ActiveSupport::Concern

    class_methods do
      def attribute(name, column_name: nil, dynamic: false)
        attributes << Attribute.new({name: name, column_name: column_name, dynamic: dynamic})
      end

      def attributes
        @attributes ||= []
      end
    end

  end

  def self.setup(master_class)
    master_class.include Helper
  end

  def perform
    builder = Builder.new(self)
    builder.build
    # headers = load_headers
    # contents = load_contents
    # exporter = Exporter::Spreadsheet.new(user, {headers: headers, contents: contents})
    # file = Paperclip::Tempfile.new(file_name)
    # open(file.path, 'wb') do |f|
    #   # case format
    #   # when :csv
    #   #   f.write exporter.generate_csv
    #   # when :xls
    #   f.write exporter.generate_xls
    #   # end
    # end
    # save_attachment(file)
    # success!
  end

  # def format
  #   params[:export_format]&.to_sym
  # end

  # def file_name
  #   # case format
  #   # when :xls
  #   return ['export', '.xls']
  #   # when :csv
  #   #   return ['export', '.csv']
  #   # else
  #   #   nil
  #   # end
  # end
  #
  # def load_headers
  #   headers = []
  #   self.master.class.attributes.each do |attribute|
  #     headers << attribute[:column_name]
  #   end
  #   headers
  # end
  #
  # def load_contents
  #   contents = []
  #   data = master.input
  #   return contents if data.nil?
  #   index = 1
  #   data.each do |entry|
  #     row = []
  #     self.master.class.attributes.each do |attribute|
  #       field = attribute[:name]
  #       if master.respond_to?(field)
  #         row << master.send(field, entry) rescue nil
  #       else
  #         raise "#{field} not defined for exporter #{master.class.name}"
  #       end
  #     end
  #     contents << row
  #     progress_update(index)
  #     index += 1
  #   end
  #   contents
  # end

end