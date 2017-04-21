class ItzCash::Dmt::Base < BaseHandler

  def env_key
    'itzcash_dmt'
  end

  def session_id
    'sessionid'
  end

  def source_id

  end

  def request_type

  end

  def query_xml_path

  end

  def query_xml_params
    {}
  end

  def query_params
    xml_path = query_xml_path
    return nil if xml_path.blank?

    xml_params = (query_xml_params or {})
    xml_params[:session_id] = session_id
    xml_params[:source_id] = source_id
    xml_params[:request_type] = request_type

    b = nil
    if xml_params.present?
      b = binding
      b.local_variable_set(:params, xml_params)
    end
    xml = ERB.new(File.read(xml_path))
    if b.present?
      xml = xml.result(b)
    end
    {inputXML: xml}
  end

  def parse
    self.parsed_response = Hash.from_xml(response.body.gsub('\n', '')).with_indifferent_access
  end

  def success?
    return false unless super
    if self.parsed_response.present?
      response_code = HashUtils.nested_search self.parsed_response, :responseCode
      if response_code.present? and response_code == 'Y'
        return true
      end
    end
    false
  end

  def failure
    response_desc = HashUtils.nested_search self.parsed_response, :responseDesc
    add_message :error, response_desc
    super
  end

end