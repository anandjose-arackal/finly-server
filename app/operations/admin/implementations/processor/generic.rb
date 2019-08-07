class Admin::Implementations::Processor::Generic < Admin::Implementations::Processor::Base

  def input
    # Implement me
  end

  def process
    export(self.headers, contents)
  end

  def contents
    contents = []
    data = input
    return contents if data.nil?
    data.each do |entry|
      row = []
      self.headers.each do |field|
        row << self.send(field, entry)
      end
      contents << row
    end
    contents
  end

end