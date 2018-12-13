class BaseHandler
  attr_accessor :params, :messages, :connection, :process_complete, :response, :user, :timeout, :parsed_response

  def self.call(user, params = {})
    self.new(user, params).run
  end

  def initialize(user, params = {})
    self.timeout = false
    self.user = user
    self.params = (ActionController::Parameters.new(params) or {})
    clear_messages
  end

  def env_key

  end

  def base_url
    if params.present? and params[:base_url].present?
      (params[:base_url] or params['base_url'])
    elsif env_key.present?
      ENV["#{env_key}_base"]
    else
      nil
    end
  end

  def path
    key = self.env_key
    if key.present?
      ENV["#{key}_path"]
    end
  end

  def query_params

  end

  def post_params

  end

  def header_params

  end

  def http_request_type
    :post
  end

  def run
    clear_messages
    authorize_user authorized_user_types
    return failure if has_errors?
    pre_validate
    return failure if has_errors?
    pre_authorize
    return failure if has_errors?
    init
    return failure if has_errors?
    authorize
    return failure if has_errors?
    validate
    return failure if has_errors?
    pre_process
    return failure if has_errors?
    process
    return failure if has_errors?
    self.process_complete = true
    post_process
    return failure if has_errors?
    parse
    return failure if has_errors?
    retrieve
  end

  # Define the authorized user types for the action
  def authorized_user_types
    # [:employee, :manager, :finance_manager, :admin]
    nil
  end

  def pre_validate

  end

  def pre_authorize

  end

  def init
    load_connection
  end

  def validate

  end

  def authorize

  end

  def pre_process

  end

  def process
    p = self.path
    query_param = self.query_params
    body_param = self.post_params
    header_param = self.header_params
    return if p.nil? or has_errors?
    begin
      unless Rails.env.production?
        puts "Posting Path : #{p}"
        puts "Post Params: #{body_param}"
      end

      request_type = http_request_type

      case request_type
      when :get
        # self.response = self.connection.post p, body_param
        self.response = self.connection.get do |req|
          req.url p
          if header_param.present? and header_param.is_a?(Hash)
            header_param.each do |k, v|
              req[k] = v
            end
          end
          req.params = query_param if query_param.present?
        end
      when :post
        # self.response = self.connection.post p, body_param
        self.response = self.connection.post do |req|
          req.url p
          req.params = query_param if query_param.present?
          if header_param.present? and header_param.is_a?(Hash)
            header_param.each do |k, v|
              req[k] = v
            end
          end
          req.body = body_param if body_param.present?
        end
      when :patch
        # self.response = self.connection.post p, body_param
        self.response = self.connection.patch do |req|
          req.url p
          req.params = query_param if query_param.present?
          req.body = body_param if body_param.present?
          if header_param.present? and header_param.is_a?(Hash)
            header_param.each do |k, v|
              req[k] = v
            end
          end
        end
      when :put
        # self.response = self.connection.post p, body_param
        self.response = self.connection.put do |req|
          req.url p
          req.params = query_param if query_param.present?
          req.body = body_param if body_param.present?
          if header_param.present? and header_param.is_a?(Hash)
            header_param.each do |k, v|
              req[k] = v
            end
          end
        end
      when :delete
        # self.response = self.connection.post p, body_param
        self.response = self.connection.delete do |req|
          req.url p
          req.params = query_param if query_param.present?
          if header_param.present? and header_param.is_a?(Hash)
            header_param.each do |k, v|
              req[k] = v
            end
          end
        end
      else
        add_message :error, 'Invalid Request Type'
        return
      end
      unless Rails.env.production?
        puts "response : #{self.response.body}"
      end
    rescue Faraday::TimeoutError, Faraday::ConnectionFailed
      self.timeout = true
      messages[:error] << 'Request timed out. Please try again'

    end
  end

  # Any post process based events such as notifications, mailers is created here
  def post_process

  end

  def parse

  end

  # This would be sent as a return value
  def retrieve
    if success?
      success
    else
      failure
    end
  end

  def has_errors?
    self.messages[:error].present?
  end

  def processing?
    not self.process_complete
  end

  def success?
    self.process_complete and not has_errors? and not self.timeout and not self.response.blank? and self.response.status == 200
  end

  def failure?
    self.process_complete and (has_errors? or self.timeout or self.response.nil? or not self.response.status == 200)
  end

  # Used to present the data to the UI
  class BaseHandler::BasePresenter
    include MathUtil, HasScope
    attr_accessor :user, :params, :messages, :config, :timeout

    def initialize(user, params = {}, messages = {})
      self.config = {}
      self.user = user
      self.params = params
      self.messages = messages
      self.timeout = params[:timeout]
      init
    end

    def init

    end

    def admin_view?
      is_view?(:admin)
    end

    def manager_view?
      is_view?(:manager)
    end

    def finance_view?
      is_view?(:finance) or is_view?(:finance_manager)
    end

    def auditor_view?
      is_view?(:auditor)
    end

    def personal_view?
      is_view?(:employee) or is_view?(:personal) or params[:view].blank?
    end

    def is_view?(type)
      type.present? and params.present? and params[:view].present? and (params[:view] == type.to_s or params[:view] == type.to_sym)
    end

    def success?
      false
    end

    def failure?
      false
    end

    class BaseHandler::BasePresenter::SuccessPresenter < BaseHandler::BasePresenter
      def success?
        true
      end

      def failure?
        false
      end
    end

    class BaseHandler::BasePresenter::FailurePresenter < BaseHandler::BasePresenter
      def success?
        false
      end

      def failure?
        true
      end
    end

  end

  protected

  def success
    BaseHandler::BasePresenter::SuccessPresenter.new(self.user, self.params, self.messages)
  end

  def failure
    self.params[:timeout] = self.timeout
    BaseHandler::BasePresenter::FailurePresenter.new(self.user, self.params, self.messages)
  end

  def load_connection(url = base_url)
    logger = Logger.new $stderr
    logger.level = Logger::INFO
    self.connection = Faraday.new(:url => url) do |faraday|
      # builder.use Faraday::Request::UrlEncoded
      if load_custom_connection(faraday)
        faraday.request :url_encoded # form-encode POST params
        faraday.response :logger, logger # log requests to STDOUT
        faraday.options[:timeout] = 60 # time out is 60 seconds
        faraday.use FaradayMiddleware::FollowRedirects, limit: 5
        faraday.adapter Faraday.default_adapter # make requests with Net::HTTP
      end
    end
  end

  def load_custom_connection(faraday)
    true
  end

  def clear_messages
    self.messages = {error: [], failure: [], success: [], message: [], notice: []}
  end

  def authorize_user(user_types)
    return if user_types.blank?
    user_types = [user_types] unless user_types.is_a?(Array)
    if user.present?
      user_types.each do |user_type|
        if (user_type == :employee and user.employee?) or (user_type == :manager and user.manager?) or
            (user_type == :finance_manager and user.finance_manager?) or (user_type == :policy_admin and user.policy_admin?) or
            (user_type == :company_admin and user.company_admin?) or (user_type == :admin and user.admin?)
          return
        end
      end
    end
    raise_unauthorized_exception
  end

  def add_message(type, message)
    return if type.blank? or message.blank? or (type != :error and type != :failure and type != :success and type != :message and type != :notice)
    clear_messages if self.messages.blank?
    if message.is_a?(Array)
      messages[type].concat message
    elsif message.is_a?(String)
      messages[type] << message
    end
  end

  def raise_unauthorized_exception
    raise NotAuthorizedException
  end

end
