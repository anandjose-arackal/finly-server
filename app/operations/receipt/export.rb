class Receipt::Export < Receipt::Index
  attr_accessor :files

  def post_process
    self.files = []
    self.receipts&.each do |receipt|
      self.files << {name: receipt.image_file_name, path: receipt.image.path}
    end
  end

  def success
    Exporter::AsZip.new(user, {name: 'receipts', files: self.files}, messages)
  end

end