class RequestFormatter::KycParser::Parse < RequestFormatter::Base

  def process
    params[:individual_kyc] = {}

    # DEPRECATED START #
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
    if params.dig(:kyc_file_1_file).present?
      params[:kyc_file_1] = extract_image(params[:kyc_file_1_file], params[:kyc_file_1_content_type], params[:kyc_file_1_file_name])
    end
    if params[:kyc_file_2_file].present?
      params[:kyc_file_2] = extract_image(params[:kyc_file_2_file], params[:kyc_file_2_content_type], params[:kyc_file_2_file_name])
    end
    if params.dig(:aadhar_front_file).present?
      params[:aadhar_front] = extract_image(params[:aadhar_front_file], params[:aadhar_front_content_type], params[:aadhar_front_file_name])
    end
    if params[:aadhar_back_file].present?
      params[:aadhar_back] = extract_image(params[:aadhar_back_file], params[:aadhar_back_content_type], params[:aadhar_back_file_name])
    end
    # DEPRECATED END #

    # Handling for Android START #
    if params.dig(:kyc_1_front_file).present?
      params[:kyc_1_front] = extract_image(params[:kyc_1_front_file], params[:kyc_1_front_content_type], params[:kyc_1_front_file_name])
    end
    if params[:kyc_1_back_file].present?
      params[:kyc_1_back] = extract_image(params[:kyc_1_back_file], params[:kyc_1_back_content_type], params[:kyc_1_back_file_name])
    end
    if params.dig(:kyc_2_front_file).present?
      params[:kyc_2_front] = extract_image(params[:kyc_2_front_file], params[:kyc_2_front_content_type], params[:kyc_2_front_file_name])
    end
    if params[:kyc_2_back_file].present?
      params[:kyc_2_back] = extract_image(params[:kyc_2_back_file], params[:kyc_2_back_content_type], params[:kyc_2_back_file_name])
    end
    if params[:photo_file].present?
      params[:photo] = extract_image(params[:photo_file], params[:photo_content_type], params[:photo_file_name])
    end
    if params[:signature_file].present?
      params[:signature] = extract_image(params[:signature_file], params[:signature_content_type], params[:signature_file_name])
    end
    # Handling for Android END #

    if params[:type_name].present?
      params[:type_id] = IndividualKycType.id_for(params[:type_name])
    end

    if params[:state_name].present?
      params[:state_id] = State.id_for(params[:state_name].downcase)
    end

    if params[:user].nil?
      params[:user] = {}
    end

    param = format_file(__dir__, 'kyc.yaml.erb', user, params)
    Formatter.handle_api_nil param

    self.formatted_request = param
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