class ExportManager::Template::TemplateExport < ExportManager::API
  attr_accessor :export_template

  def initialize(user, params)
    super(user, params)
    self.export_template = ExportTemplateNew.find(template_id)
  end

  # TODO: remove this function
  def self.sync
    true
  end

  def input
    # TODO: merge default query params in template to params

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

      results = results.includes(includes)
    end

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
    processor = processor_class.new export_job
    file = processor.generate template, data, file_name
    if file
      save_attachment file
      success!
    else
      failure!
    end
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
