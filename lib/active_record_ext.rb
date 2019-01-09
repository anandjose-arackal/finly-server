module ActiveRecordExt
  def log(query, *)
    if self.class <= NonPersistentModel
      super
    else
      QueryLogger.log(query) {super}
    end
  end
end