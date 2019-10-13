class Bbps::BillersList < ServiceApi
  include Bbps::Setup

  schema do
    params do
      required(:category).filled
    end
  end

  request_fields(
      [
          :message_code, :ref_number, :agent_institution_id, :channel_id, :category, :last_updated_timestamp,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field
      ]
  )

  response_fields(
      [
          :message_code, :status, :error_code, :error_desc, :ref_no, :agent_institution_id,
          :channel_id, :billers_list,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
          :additional_field, :additional_field, :additional_field, :additional_field, :additional_field
      ]
  )


  def category
    params[:category]
  end

  def on_success(result)
    list = JSON.parse(result[:billers_list])
    list.map { |item| OpenStruct.new(item) }
  end

end