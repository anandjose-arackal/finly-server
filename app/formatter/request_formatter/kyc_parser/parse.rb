class RequestFormatter::KycParser::Parse < RequestFormatter::Base

  def process
    if params.dig(:address_proof_file).present?
      # Handling for Android
      params[:address_proof] = extract_image(params[:address_proof_file], params[:address_proof_content_type], params[:address_proof_file_name])
    end
    if params[:id_proof_file].present?
      params[:id_proof] = extract_image(params[:id_proof_file], params[:id_proof_content_type], params[:id_proof_file_name])
    end
    params[:individual_kyc] = {}
    params[:individual_kyc][:address_proof] = params[:address_proof] if params[:address_proof].present?
    params[:individual_kyc][:id_proof] = params[:id_proof] if params[:id_proof].present?
    self.formatted_request = params
  end

  def extract_image(data, content_type, file_name)
    return data if data.blank?
    file = data.tempfile
    file.class.class_eval { attr_accessor :original_filename, :content_type }
    file.original_filename = file_name
    file.content_type = content_type
    file
  end

end