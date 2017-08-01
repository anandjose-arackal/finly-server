require 'liquid'
require 'securerandom'
require 'faraday'
require 'awesome_print'

URL = 'https://uatsky.yesbank.in/app/uat/ssl/fundsTransferByCustomerSevice2'

BASIC_AUTH_USERNAME = "testclient"
BASIC_AUTH_PASSWORD = "test@123"
DP_CLIENT_ID        = "7b1f3f3e-c77a-445f-8471-1fe808b7836c"
DP_CLIENT_SECRET    = "eI5bR5yL5tT3jO0yP0wO8cT1xI4dD7uS1mU3rW8nN1bN0iI2iM"
CUSTOMER_ID         = "448995"
ACCOUNT_NUMBER      = "000690600003544"

def load_template(template_name)
  p 'loading template'
  return Liquid::Template.parse(File.read(template_name))
end

def connect_to_bank
  ssl_options = {
    client_cert: OpenSSL::X509::Certificate.new(File.read('finly.crt')),
    client_key: OpenSSL::PKey::RSA.new(File.read('finly.key')),
    ca_path: './ybl.pem',
    verify: false
  }
  conn = Faraday.new(:url => URL, :ssl => ssl_options) do |c|
    c.use Faraday::Request::UrlEncoded
    c.use Faraday::Request::BasicAuthentication, BASIC_AUTH_USERNAME, BASIC_AUTH_PASSWORD
    c.use Faraday::Response::Logger
    c.use Faraday::Adapter::NetHttp
  end
  return conn
end

def send_request(conn, template)
  p "send_request"
  puts template

  response = conn.post do |req|
     req.headers['Content-Type'] = 'application/xml'
     req.headers["X-IBM-Client-Id"] = DP_CLIENT_ID
     req.headers["X-IBM-Client-Secret"] = DP_CLIENT_SECRET
     req.body = template
  end
  ap response.body
end

def run_get_status
  conn = connect_to_bank
  template = load_template('getstatus.template')
  send_request(conn, template.render('CUSTOMER_ID' => CUSTOMER_ID, 'ACCOUNT_NUMBER' => ACCOUNT_NUMBER))
end

run_get_status