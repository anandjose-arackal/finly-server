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
            receipt.document_slices.each do |document_slice|
              path = document_slice.image.url
              receipts << {merchant: expense.merchant_name, amount: expense.amount_value, path: path}
            end
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