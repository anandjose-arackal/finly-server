class GstStateCodeExposure < Exposures::API

  def code
    record.state_code
  end

  def name
    record.name
  end

end