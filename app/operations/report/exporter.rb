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