class Forms::Extractor

  def self.fetch(entity_path, form: nil, row: nil)
    splits = entity_path.split("/")
    key = splits.last
    return row[key] if row[key].present?
    return row[entity_path] if row[entity_path].present?
    return form[entity_path] if form[entity_path].present?
    return HashUtils.deep_fetch(form, entity_path, delimiter: '/')
  end

end