class ExportManager::Generators::Spreadsheet::Header

  def list
    @list ||= []
  end

  def add(name)
    list << name unless list.include?(name)
  end

end