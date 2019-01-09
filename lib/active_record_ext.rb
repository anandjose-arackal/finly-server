module ActiveRecordExt
  def log(query, *)
    QueryLogger.log(query) { super }
  end
end