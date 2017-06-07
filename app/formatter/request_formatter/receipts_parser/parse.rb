class RequestFormatter::Receipts::Parse < RequestFormatter::Base

  def process
    if params[:receipt].present? and not params[:receipt] == 'nil'
      image = extract_receipt_image(params)
      params[:receipt] = {}
      params[:receipt][:image] = image
      params[:receipt][:user_id] = user.id
    end
    self.formatted_request = params
  end

  def extract_receipt_image(params)
    data = params[:receipt]
    file = data.tempfile
    file.class.class_eval { attr_accessor :original_filename, :content_type }
    file.original_filename = params[:filename]
    file.content_type = params[:content_type]
    file
  end

end