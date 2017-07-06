json.registered @result.registered
json.verified @result.verified
json.otp_verified @result.otp_verified
json.success @result.success?
json.set_password !!@result.params&.dig(:set_password)
json.id @result.id if @result.id.present?
json.mobile_number @result.mobile_number if @result.mobile_number.present?