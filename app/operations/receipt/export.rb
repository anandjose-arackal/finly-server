class Receipt::Export < Receipt::Base
  attr_accessor :receipts, :files

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    receipts_presenter = Receipt::Index.(user, params)
    unless receipts_presenter.success?
      add_message :error, receipts_presenter.messages[:error]
      return
    end
    self.receipts = receipts_presenter.receipts
    if params[:id].present? or params[:receipt_id].present?
      id = (params[:receipt_id] or params[:id])&.split(',')
      self.receipts = self.receipts.with_id(id)
    end
  end

  def validate
    if self.receipts.blank?
      add_message :error, 'Receipt not found'
    end
  end

  def process
    self.files = []
    self.receipts&.each do |receipt|
      self.files << {name: receipt.export_image_file_name, url: receipt.image.url}
    end
  end

  def success
    Exporter::AsZip.new(user, {name: 'receipts', files: self.files}, messages)
  end

end