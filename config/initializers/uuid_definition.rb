module UUIDDefinition
  def uuid(*columns)
    options = columns.extract_options!
    options[:index] ||= true
    options[:limit] ||= 36
    options[:null] ||= false
    columns.each {|name| column(name, 'string', options)}
  end
end

ActiveRecord::ConnectionAdapters::TableDefinition.include UUIDDefinition