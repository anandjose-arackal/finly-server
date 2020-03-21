class StateExposure < Exposures::API

  def code
    record.code
  end

  def name
    record.name
  end

end