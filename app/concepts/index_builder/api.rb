class IndexBuilder::API
  include Column::Builder
  include DynamicAttributes

  class_attr :resolver

  def self.config(user)
    config = {fixed: [], dynamic: []}
    columns.each do |column_key, column|
      if column.fixed
        config[:fixed] << column.config(user)
      else
        config[:dynamic] << column.config(user)
      end
    end
    config
  end

  def self.build(user, record, required_columns)
    map = {}
    self.columns.each do |column_key, column|
      next if required_columns.present? and not (required_columns.include?(column_key.to_s) or required_columns.include?(column_key.to_sym))
      next if required_columns.blank? and not column.default

      map[column.column_key] = column.build(self, user, record)
    end
    map
  end

  def self.include_associations!(collection, required_columns)
    includes = []
    attrs =  columns.select do |column_key, attr|
      (required_columns.blank? and attr.default) or (required_columns.present? and (required_columns.include?(column_key.to_s) or required_columns.include?(column_key.to_sym)))
    end
    attrs.each do |column_key, column|
      includes += column.includes
    end
    collection.includes(includes.uniq)
  end

end