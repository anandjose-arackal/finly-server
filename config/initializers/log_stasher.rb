# if LogStasher.enabled?
#   LogStasher.add_custom_fields do |fields|
#     # This block is run in application_controller context,
#     # so you have access to all controller methods
#     fields[:request_params] = params
#     user = current_user rescue nil
#     if user.present?
#       fields[:user_id] = user&.id
#       fields[:user_name] = (user&.name rescue nil)
#       fields[:user_email] = user&.email
#       fields[:user_mobile_number] = user&.mobile_number
#       fields[:current_app] = current_app
#       fields[:current_device] = current_device
#       fields[:company_name] = (current_company&.name rescue nil)
#       fields[:company_id] = (current_company&.id rescue nil)
#       view = (params&.dig(:view) rescue nil)
#       fields[:current_view] = view
#     end
#     # If you are using custom instrumentation, just add it to logstasher custom fields
#     # LogStasher.custom_fields << :myapi_runtime
#   end
#
#   # LogStasher.add_custom_fields_to_request_context do |fields|
#   #   # This block is run in application_controller context,
#   #   # so you have access to all controller methods
#   #   # You can log custom request fields using this block
#   #   fields[:user] = current_user && current_user.mail
#   #   fields[:site] = request.path =~ /^\/api/ ? 'api' : 'user'
#   # end
# end