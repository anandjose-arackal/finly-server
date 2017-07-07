json.registered @result.registered
json.verified @result.verified
json.otp_verified @result.otp_verified
json.success @result.success?
json.df @result.params&.dig(:set_password)