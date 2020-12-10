class ExportManager::Template::TemplateExport < ExportManager::API
  attr_accessor :export_template, :processor, :file

  def initialize(user, params)
    super(user, params)
    self.export_template = ExportTemplateNew.find(template_id)
  end

  # TODO: remove this function
  # def self.sync
  #   true
  # end

  def build_name
    export_template.name
  end

  def format_query(query)
    conditions = []
    groups = []
    query["c"] ||= []
    query["g"] ||= []

    query["c"].each do |sub_query|
      unless sub_query["_destroy"]
        if sub_query["logic_type"] == "group"
          groups << format_query(sub_query)
        else
          conditions << sub_query
        end
      end
    end

    query["c"] = conditions
    query["g"] = groups
    query
  end

  def input
    if self.export_template.query.present?
      query = self.export_template.query
      if query["q"].present?
        query["q"] = format_query({"c" => query["q"]})
      end
      params[:additional_filters] = [query.with_indifferent_access]
    end
    results = Resolver::Router.dispatch("#{resource_type}.default", { current_user: user, params: params })

    case format
    when :csv, :xls
      includes = Exposures::IncludesCalculator.(
        results.model,
        template['columns'].map do |column|
          column['value']
        end,
        'record'
      )
    else
      includes = Exposures::IncludesCalculator.(
        results.model,
        [template],
        'records'
      )
    end
    results = results.includes(includes)

    results
  end

  def resource_type
    export_template.resource
  end

  def template_id
    params[:template_id]
  end

  def template
    case format
    when :csv, :xls
      JSON.parse(export_template.template)
    else
      export_template.template
    end
  end

  def processor_class
    case format
    when :xls
      ExportManager::Template::Processors::XlsProcessor
    when :csv
      ExportManager::Template::Processors::CSVProcessor
    when :xml
      ExportManager::Template::Processors::XmlProcessor
    when :json
      ExportManager::Template::Processors::JsonProcessor
    when :other
      ExportManager::Template::Processors::TextProcessor
    end
  end

  def generate
    self.processor = processor_class.new export_job
    self.file = self.processor.generate template, data, file_name
    if self.file
      save_attachment self.file
      success!
    else
      failure!
    end
  end

  def update_current_record
    self.processor.update_current_record
  end

  def file_name
    # TODO: update to include template name in file name
    case format
    when :csv
      ['export', '.csv']
    when :xls
      ['export', '.xls']
    when :json
      ['export', '.json']
    when :xml
      ['export', '.xml']
    when :other
      ['export']
    end
  end

  def format
    export_template.export_format.to_sym
  end
end
