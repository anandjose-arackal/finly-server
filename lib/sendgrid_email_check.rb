# require 'sendgrid-ruby'
# include SendGrid
# # Encapsulates demo email send functionality using sendgrid
# class SendGridEmailCheck
#   def initialize
#     @sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
#   end
#   def send_email
#     response = @sg.client.mail._('send').post(JSON.parse('{
#       "from": {
#         "email": "ramanbedi1989@gmail.com",
#         "name": "Raman Bedi"
#       },
#       "personalizations": [{
#         "to": [
#           {
#           "email": "ramanbedi1989@gmail.com",
#           "name": "Raman Bedi"
#           }
#         ]
#       }],
#       "content": [{
#         "type": "text/html",
#         "value": "<html><p>Hello, world!</p></html>"
#       }],
#       "subject": "Hello, World!"
#     }'))
#     puts response.status_code
#     puts response.body
#     puts response.headers
#   end
# end
