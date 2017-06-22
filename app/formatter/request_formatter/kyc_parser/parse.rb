class RequestFormatter::KycParser::Parse < RequestFormatter::Base

  def process
    if params[:individual_kyc].present?
      pan_card = extract_image(params, :pan_card)
      id_proof = extract_image(params, :id_proof)
      params[:individual_kyc] = {}
      params[:individual_kyc][:pan_card] = pan_card
      params[:individual_kyc][:id_proof] = id_proof
    end
    self.formatted_request = params
  end

  def extract_image(params, key)
    data = params[key]
    return data if data.blank?
    file = data.tempfile
    file.class.class_eval { attr_accessor :original_filename, :content_type }
    file.original_filename = params[:filename]
    file.content_type = params[:content_type]
    file
  end

end