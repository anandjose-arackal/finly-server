module ReceiptProcessor
  # encapsulates functionality for PDF to image conversion
  class PDFConverter
    def convert(doc, image_tmp_path)
      # Instead of converting pdfs to images and storing the images we are storing the pdf directly

      # images = []
      # pdf_pages = Magick::ImageList.new(open(doc)) { self.density = 300 }
      # pdf_pages.each_with_index do |pdf_page, index|
      #   updated_image_path = image_tmp_path.gsub(/(.*)\.(.*)$/, "\\1_#{index}.\\2")
      #   pdf_page.write updated_image_path
      #   pdf_image = File.open(updated_image_path)
      #   images << pdf_image
      # end
      # images

      images = []
      images.push File.open doc
    end
  end
end
