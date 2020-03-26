class CategoryExposure < Exposures::API

  def name
    record.name
  end

  def gl_code
    record.gl_code
  end

end