class Forms::Extractor

  def self.fetch(entity_path, form: nil, row: nil)
    splits = entity_path.split("/")
    key = splits.last
    return row[key] if row[key].present?
  end

end