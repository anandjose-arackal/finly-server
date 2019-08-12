class Admin::Implementations::Processor::Export < Admin::Implementations::Processor::Base

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
    self.implementation_request.update(requested_items: data.count)
    data.each_with_index do |entry, index|
      row = []
      self.headers.each do |field|
        row << self.send(field, entry)
      end
      contents << row
      item_complete true
    end
    contents
  end

end