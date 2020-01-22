class ExportManager::Builders::Spreadsheet::Header

  def list
    @list ||= []
  end

  def add(name)
    name = name&.to_s
    list << name unless list.include?(name)
  end

end