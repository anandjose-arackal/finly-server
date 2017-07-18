class RequestFormatter::KycParser::Parse < RequestFormatter::Base

  def process
    params[:individual_kyc] = {}

    # DEPRICATED START #
    # Handling for Android START #
    if params.dig(:address_proof_file).present?
      params[:address_proof] = extract_image(params[:address_proof_file], params[:address_proof_content_type], params[:address_proof_file_name])
    end
    if params[:id_proof_file].present?
      params[:id_proof] = extract_image(params[:id_proof_file], params[:id_proof_content_type], params[:id_proof_file_name])
    end
    # Handling for Android END #
    params[:individual_kyc][:address_proof] = params[:address_proof] if params[:address_proof].present?
    params[:individual_kyc][:id_proof] = params[:id_proof] if params[:id_proof].present?
    # DEPRICATED END #


    # Handling for Android START #
    if params.dig(:kyc_file_1_file).present?
      params[:kyc_file_1] = extract_image(params[:kyc_file_1_file], params[:kyc_file_1_content_type], params[:kyc_file_1_file_name])
    end
    if params[:kyc_file_2_file].present?
      params[:kyc_file_2] = extract_image(params[:kyc_file_2_file], params[:kyc_file_2_content_type], params[:kyc_file_2_file_name])
    end
    # Handling for Android END #

    params[:individual_kyc][:kyc_file_1] = params[:kyc_file_1] if params[:kyc_file_1].present?
    params[:individual_kyc][:kyc_file_2] = params[:kyc_file_2] if params[:kyc_file_2].present?
    params[:individual_kyc][:kyc_number] = params[:kyc_number] if params[:kyc_number].present?
    params[:individual_kyc][:type_id] = params[:type_id] if params[:type_id].present?
    if params[:type_name].present?
      params[:individual_kyc][:type_id] = IndividualKycType.id_for(params[:type_name])
    end

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