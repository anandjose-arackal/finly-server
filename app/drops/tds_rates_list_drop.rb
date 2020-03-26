class TdsRatesListDrop < Drop

  def name
    record.name
  end

  def rate
    record.tds
  end

  def gl_code
    record.gl_code
  end

end