json.success @result.success?
json.registered @result.registered
json.verified @result.verified
json.otp_verified @result.otp_verified
if @result.set_password
  json.set_password !!@result.set_password
  json.mobile_number @result.mobile_number
end