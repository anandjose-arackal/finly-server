class CostCenterExposure < Exposures::API

  def gl_code
    record.gl_code
  end

  def name
    record.name
  end

end