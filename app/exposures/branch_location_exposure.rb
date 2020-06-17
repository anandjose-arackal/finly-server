class BranchLocationExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :location_code, record_attribute: true

  def name
    record.name
  end

  def gstin
    record.gstin
  end

  def state
    record.state
  end

  def gl_code
    record.gl_code
  end

end