class ExportTemplates::BaseGenerator < Transaction

  step :verify_params
  step :process_request

  def verify_params(options, params: {}, **)
    unless params['template'].present?
      return error(options, 'template', 'not found')
    end
    unless params['data'].present?
      return error(options, 'data', 'not found')
    end
    options['template'] = params['template']
    options['data'] = params['data']
    options['configuration'] = params['template'].configuration
    true
  end

  def process_request(options, data:, configuration:, template:, **)
    raise 'Cannot process export template as it is in base class'
  end

end