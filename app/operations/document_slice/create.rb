class DocumentSlice::Create < BackgroundOperation
  attr_accessor :receipt, :tempfile, :base_path

  def init
    self.receipt = Receipt.find_by(params[:receipt_id])
    self.base_path = "#{Rails.root}/public/tmp"
    FileUtils::mkdir_p base_path
    self.tempfile = Tempfile.new('temp_export')
    open(tempfile.path, 'wb') do |file|
      file << open(receipt.image.url).read
    end
  end

  def process
    Magick::ImageList.new(tempfile.path) do
      self.quality = 100
      self.density = '150'
      self.colorspace = Magick::RGBColorspace
      self.interlace = Magick::NoInterlace
    end.each_with_index do |img, i|
      path = "#{base_path}/#{receipt.id}_#{DateTime.now.strftime('%Q')}-#{i}.jpg"
      img.write(path)
      document_slice = receipt.document_slices.build(page_number: i, image: File.open(path), receipt_id: receipt.id)
      document_slice.save
    end
    tempfile.delete
  end
end