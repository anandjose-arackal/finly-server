module ReceiptProcessor
  # encapsulates functionality for html to image conversion
  class HTMLConverter
    def convert(html_string, image_tmp_path)
      images = []
      html_image = File.new image_tmp_path, 'wb'
      kit = IMGKit.new html_string, :quality => 100
      html_image.write(kit.to_img)
      html_image.rewind
      images << html_image
    end
  end
end
