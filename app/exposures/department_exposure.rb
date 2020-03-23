class DepartmentExposure < Exposures::API

  def gstin
    record.gstin
  end

  def name
    record.name
  end

  def gl_code
    record.gl_code
  end

end