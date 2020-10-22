# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'

# Ruby client for bullet-train.io
class BulletTrain
  attr_reader :bt_api

  TIMEOUT = 30

  def self.logger
    @logger ||= LogStashLogger.new(type: :file, path: 'log/bullet_train_api.log', sync: true)
  end

  def initialize(opts = {})
    @opts = determine_opts(opts)

    @bt_api = Faraday.new(url: @opts[:url], request: {timeout: TIMEOUT}) do |faraday|
      faraday.headers['Accept'] = 'application/json'
      faraday.headers['Content-Type'] = 'application/json'
      faraday.headers['x-environment-key'] = @opts[:api_key]
      faraday.response :json
      # TODO: add timeout adjustment here
      faraday.adapter Faraday.default_adapter
    end
  end

  def request(method, path, *args)
    start_time = Time.now
    res = @bt_api.send(method, path, *args)
    time = (Time.now - start_time).to_f
    response_body = res.status != 200 ? res.body : nil
    # Todo log only if the response is slower than 2s
    self.class.logger.info({duration: time, status: res.status, method: method, response_body: response_body, path: path, request_args: args})
    res
  end

  def get_flags(user_id = nil)
    if user_id.nil?
      res = request(:get, 'flags/')
      flags = transform_flags(res.body).select { |flag| flag[:segment].nil? }
      flags_to_hash(flags)
    else
      res = request(:get, "identities/?identifier=#{user_id}")
      flags_to_hash(transform_flags(res.body['flags']))
    end
  end

  def feature_enabled?(feature, user_id = nil, default = false)
    flag = get_flags(user_id)[normalize_key(feature)]
    return default if flag.nil?

    flag[:enabled]
  end

  def get_value(key, user_id = nil, default = nil)
    flag = get_flags(user_id)[normalize_key(key)]
    return default if flag.nil?

    flag[:value]
  end

  def set_trait(user_id, trait, value)
    raise StandardError, 'user_id cannot be nil' if user_id.nil?

    trait = {
        identity: {identifier: user_id},
        trait_key: normalize_key(trait),
        trait_value: value
    }
    res = request(:post, 'traits/', trait.to_json)
    res.body
  end

  def get_traits(user_id)
    return {} if user_id.nil?

    res = request(:get, "identities/?identifier=#{user_id}")
    traits_to_hash(res.body)
  end

  def incr_counter(user_id, trait, incr_by = 1)
    raise StandardError, 'user_id cannot be nil' if user_id.nil?

    trait = {
        identifier: user_id,
        trait_key: normalize_key(trait),
        increment_by: incr_by
    }
    res = request(:post, 'traits/increment-value/', trait.to_json)
    res.body
  end

  # def remove_trait(user_id, trait_id)
  #   # Request URL: https://api.bullet-train.io/api/v1/environments/API_KEY/identities/12345/traits/54321/
  #   # Request Method: DELETE
  # end

  def transform_flags(flags)
    flags.map do |flag|
      {
          name: flag['feature']['name'],
          enabled: flag['enabled'],
          value: flag['feature_state_value'],
          segment: flag['feature_segment']
      }
    end
  end

  def flags_to_hash(flags)
    result = {}
    flags.each do |flag|
      key = normalize_key(flag.delete(:name))
      result[key] = flag
    end
    result
  end

  def traits_to_hash(user_flags)
    result = {}
    user_flags['traits']&.each do |t|
      key = normalize_key(t['trait_key'])
      result[key] = t['trait_value']
    end
    result
  end

  def normalize_key(key)
    key.to_s.downcase
  end

  def determine_opts(opts)
    opts = {api_key: opts} if opts.is_a? String

    {
        api_key: opts[:api_key] || self.class.api_key,
        url: opts[:url] || self.class.api_url
    }
  end

  alias hasFeature feature_enabled?
  alias getValue get_value
  alias getFlags get_flags
  alias getFlagsForUser get_flags

  def self.api_key
    ENV['BULLETTRAIN_API_KEY']
  end

  def self.api_url
    ENV.fetch('BULLETTRAIN_URL') { 'https://api.bullet-train.io/api/v1/' }
  end
end
