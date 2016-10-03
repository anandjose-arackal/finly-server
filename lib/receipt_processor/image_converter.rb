module ReceiptProcessor
  # encapsulates functionality for image to image conversion - used only for symantics
  class ImageConverter
    def convert(doc_path, _image_tmp_path)
      images = []
      images.push File.open doc_path
    end
  end
end
