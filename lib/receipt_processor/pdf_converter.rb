module ReceiptProcessor
  # encapsulates functionality for PDF to image conversion
  class PDFConverter
    def convert(doc, image_tmp_path)
      images = []
      pdf_pages = Magick::ImageList.new(open(doc))
      pdf_pages.each_with_index do |pdf_page, index|
        updated_image_path = image_tmp_path.gsub(/(.*)\.(.*)$/, "\\1_#{index}.\\2")
        pdf_page.write updated_image_path
        pdf_image = File.open(updated_image_path)
        images << pdf_image
      end
      images
    end
  end
end
