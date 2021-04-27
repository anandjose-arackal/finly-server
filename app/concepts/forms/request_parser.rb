class Forms::RequestParser

  attr_accessor :form, :row, :meta

  def initialize(form: {}, row: {}, meta: {})
    self.form = form || {}
    self.row = row || {}
    self.meta = meta || {}
  end

  def fetch(entity_path)
    splits = entity_path.split(".")
    key = splits.last
    return row[key] if row[key].present?
    return row[entity_path] if row[entity_path].present?
    return form[entity_path] if form[entity_path].present?

    HashUtils.deep_fetch(form, entity_path, delimiter: '.')
  end

end