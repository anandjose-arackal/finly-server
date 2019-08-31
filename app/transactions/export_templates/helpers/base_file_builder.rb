class ExportTemplates::Helpers::BaseFileBuilder < Transactions::API

  step :verify_params
  step :build_file

  def verify_params(options, params: {}, **)
    unless params['template'].present?
      return on_error(options, 'template', 'not found')
    end
    unless params['data'].present?
      return on_error(options, 'data', 'not found')
    end
    options['template'] = params['template']
    options['data'] = params['data']
    options['configuration'] = params['template'].configuration
    true
  end

  def build_file(options, data:, configuration:, template:, **)
    raise 'Cannot process export template as it is in base class'
  end

  def set_file_data(options, data)
    options['result.file_data'] = data
  end

end