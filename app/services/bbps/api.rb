class Bbps::Api < ServiceApi
  include Setup

  class_attr :request_fields, default: []
  class_attr :response_fields, default: []

  def generate_request

  end

  def client

  end

  module Setup
    def self.included(base)
      base.http_method :post
      base.client :client
      base.body do |user, params|

      end
      base.parse
    end
  end

end