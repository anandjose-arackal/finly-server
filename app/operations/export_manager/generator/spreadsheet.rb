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

  # Responsible for generating the file
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

    # Converts input records to array of Row Objects. Each row object contains a hash of the columns and values
    def generate_rows
      master.class.attributes.each do |attr|
        next if attr.dynamic

        header.add attr.column_name
      end

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
  end

end