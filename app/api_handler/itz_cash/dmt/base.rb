class ItzCash::Dmt::Base < ItzCash::Base

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

end