class Docs::UtilityBills::Bills::Ops::HandleFetchErrors < Transactions::API

  step :init
  step :process

  def init(options, params:, **)
    error_message = params[:result]&.dig("result.operation.errors")&.dig("base")&.first
    if error_message.present?
      options[:error_message] = error_message
      options[:bbps_response_messages] = YAML.load_file("#{Rails.root}/config/bbps_error.yml")
    end
  end


  def process(options, params:, bbps_response_messages:, error_message:, **)
    subscription = params[:subscription]

    if bbps_response_messages["BillFetchNoDueResponses"].include?(error_message)
      # No Pending Bills (Well mostly)

      subscription.update({
                              refreshed_at: DateTime.now,
                              biller_response: error_message,
                          })

    elsif bbps_response_messages["BillFetchErrorResponses"].include?(error_message)
      # Something wrong with subscription, will add error response to subscription

      subscription.update({
                              refreshed_at: DateTime.now,
                              biller_response: error_message,
                              auto_fetch_enabled: false,
                          })

    else
      # Other Cases | Should not reach here

      subscription.update({
                              refreshed_at: DateTime.now,
                              biller_response: error_message,
                              auto_fetch_enabled: false,
                          })

    end

    subscription.update(update_params) if update_params.present?

    true

  end

end