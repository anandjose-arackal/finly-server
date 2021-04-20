require 'rmagick'
require 'fileutils'

class Reports::ExportHandler < Reports::Show

  def success
    params[:report] = self.report
    Reports::ExportHandler::SuccessPresenter.new(self.user, params, messages)
  end

  class Reports::ExportHandler::SuccessPresenter < Reports::Base::Presenter

    attr_accessor :local_variables, :template

    def init
      super
      self.local_variables = {
        report: self.report,
        receipts: self.receipts,
        includes_comments: true
      }
      if self.user.company.custom_export_configuration.custom_report && File.exists?("#{Rails.root}/app/views/export/report_#{self.user.company_id}.pdf.erb")
        self.template = "export/report_#{self.user.company_id}"
      else
        self.template = "export/report"
      end
    end

    def receipts
      receipts = []
      self.report.expenses.each do |expense|
        expense.receipts.includes(:document_slices).each do |receipt|
          if receipt.is_pdf?
            ## As ImageMagick was throwing an exception while trying to read the file from S3, resorted to this alternate.
            #tempfile = Tempfile.new('temp_export')
            #open(tempfile.path, 'wb') do |file|
            #  file << open(receipt.image.url).read
            #end
            #
            #Magick::ImageList.new(tempfile.path) do
            #  self.quality = 95
            #  self.density = '300'
            #  self.colorspace = Magick::RGBColorspace
            #  self.interlace = Magick::NoInterlace
            #end.each_with_index do |img, i|
            #  #img.resize_to_fit!(800, 800)
            #  path = "#{base_path}/#{receipt.id}_#{DateTime.now.strftime('%Q')}-#{i}.jpg"
            #  img.write(path)
            #  receipts << {merchant: expense.merchant_name, amount: expense.amount_value, path: path}
            #end
            #tempfile.delete
          else
            path = receipt.image.url
            receipts << {merchant: expense.merchant_name, amount: expense.amount_value, path: path}
          end
        end
      end
      receipts
    end

  end

end