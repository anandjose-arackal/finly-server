require 'RMagick'
require 'fileutils'

class Report::Exporter < Report::Show

  def success
    params[:report] = self.report
    Report::Exporter::SuccessPresenter.new(self.user, params, messages)
  end

  class Report::Exporter::SuccessPresenter < Report::Base::Presenter

    def receipts
      receipts = []
      base_path = "#{Rails.root}/public/tmp"
      FileUtils::mkdir_p base_path
      self.report.expenses.each do |expense|
        expense.receipts.each do |receipt|
          if receipt.is_pdf?
            url = receipt.image.url
            if url.starts_with?('//')
              url = "https:#{url}"
            end
            Magick::ImageList.new(url) do
              self.quality = 95
              self.density = '300'
              self.colorspace = Magick::RGBColorspace
              self.interlace = Magick::NoInterlace
            end.each_with_index do |img, i|
              #img.resize_to_fit!(800, 800)
              path = "#{base_path}/#{receipt.id}_#{DateTime.now.strftime('%Q')}-#{i}.jpg"
              img.write(path)
              receipts << {merchant: expense.merchant_name, amount: expense.amount_value, path: path}
            end
          else
            url = receipt.image.url
            if url.starts_with?('//')
              url = "https:#{url}"
            end
            receipts << {merchant: expense.merchant_name, amount: expense.amount_value, url: url}
          end
        end
      end
      receipts
    end

  end

end