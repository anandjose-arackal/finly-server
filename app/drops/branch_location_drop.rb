class BranchLocationDrop < Drop

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