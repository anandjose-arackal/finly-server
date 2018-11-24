class TrackerListener
  @queue = :usage_logger

  # Inactivity time before a new visit is created
  VISIT_DURATION = 30.minutes

  # FILE_LOGGER = Logger.new(Rails.root.join('log/verify_handler.log'))
  LOGGER = Logger.new(STDOUT)

  def self.add_event(user_id, device, app, path, controller, action, remote_ip, method, datetime)
    # Track only if user is present
    return false if user_id.blank? or remote_ip.blank?
    visit = TrackerVisit.with_user_id(user_id).with_device(device).with_ip(remote_ip).started_after(max_last_visit_time(datetime))&.first
    return false unless visit
    # Log visit
    event = visit.events.build app: app, path: path, controller: controller, action: action, http_method: method
    event.valid? and event.save
  end

  def self.enqueue(request, params, company_id, user_id, device, app)
    args = {
        company_id: company_id,
        user_id: user_id,
        device: device,
        app: app,
        path: request.path,
        method: request.method_symbol,
        landing_page: request.original_url,
        user_agent: StringUtils.force_utf_8_encoding(request.user_agent),
        referrer: request.referer,
        remote_ip: request.remote_ip,
        controller: params[:controller],
        action: params[:action],
        platform: params[:platform],
        app_version: params[:app_version],
        os_version: params[:os_version],
        screen_height: params[:screen_height],
        screen_width: params[:screen_width],
        started_at: DateTime.now.to_s
    }

    Resque.enqueue TrackerListener, args
  end

  def self.max_last_visit_time(datetime)
    datetime - TrackerListener::VISIT_DURATION
  end

  # Background service which keeps listening to events
  def self.run
    LOGGER.info 'Starting tracker listener'
    LOGGER.info 'Awaiting Requests'
    begin
      loop do
        request = Resque.reserve(@queue)
        next unless request.present?
        args = request.args.first
        LOGGER.info "New request : #{args['controller']}/##{args['action']}"
        request = TrackerListener::VisitProperties.new args

        # As servers can handle multiple concurrent requests, to prevent multiple visits from being created, run add_event again
        if add_event request.user_id, request.device, request.app, request.path, request.controller, request.action, request.remote_ip, request.method, DateTime.parse(request.started_at)
          LOGGER.info "Part of existing visit. Event added"
          next
        end

        visit = TrackerVisit.new request.visit_attrs
        unless visit&.valid?
          LOGGER.info "Failed to create visit. Reason : #{visit.errors.full_messages}"
          next
        end
        visit.save
        LOGGER.info "Created visit with ID #{visit.id}"
        event = visit.events.build app: request.app, path: request.path, controller: request.controller, action: request.action, http_method: request.method
        unless event.valid?
          LOGGER.info "Failed to create event. Reason : #{event.errors.full_messages}"
          next
        end
        event.save
        LOGGER.info "Created event with ID #{event.id}"
      end
    rescue SystemExit, Interrupt
      LOGGER.info 'Scheduling Exit'
      # LOGGER.info 'Waiting for workers to complete'
      LOGGER.info 'Bye'
    end
  end

  class TrackerListener::VisitProperties
    attr_accessor :args, :company_id, :user_id, :device, :app, :path,
                  :method, :controller, :action, :referrer, :landing_page,
                  :remote_ip, :platform, :app_version, :os_version, :screen_height,
                  :screen_width, :user_agent, :started_at

    def initialize(args)
      self.args = args
      self.company_id = args['company_id']
      self.user_id = args['user_id']
      self.device = args['device']
      self.app = args['app']
      self.path = args['path']
      self.method = args['method']
      self.controller = args['controller']
      self.action = args['action']
      self.landing_page = args['landing_page']
      self.referrer = args['referrer']
      self.remote_ip = args['remote_ip']
      self.platform = args['platform']
      self.app_version = args['app_version']
      self.os_version = args['os_version']
      self.screen_height = args['screen_height']
      self.screen_width = args['screen_width']
      self.user_agent = args['user_agent']
      self.started_at = args['started_at']
    end

    def visit_attrs
      attrs = request_properties
      attrs.merge!(location_properties)
      attrs.merge!(utm_properties)
      attrs.merge!(tech_properties)
      attrs
    end

    def location_properties
      result = Geocoder.search(self.remote_ip)&.first
      {
          ip_type: result&.data&.dig('type'),
          continent_name: result.continent_name,
          continent_code: result.continent_code,
          country_name: result.country_name,
          country_code: result.country_code,
          region_code: result.region_code,
          region_name: result.region_name,
          city: result.city,
          zip: result.zip
      }
    end

    def utm_properties
      landing_uri = Addressable::URI.parse(self.landing_page) rescue nil
      landing_params = landing_uri&.query_values || {}

      props = {}
      %w(utm_source utm_medium utm_term utm_content utm_campaign).each do |name|
        props[name.to_sym] = landing_params[name]
      end
      props
    end

    # def traffic_properties
    #   # cache for performance
    #   @@referrer_parser ||= RefererParser::Parser.new
    #
    #   {
    #       referring_domain: (Addressable::URI.parse(referrer).host.first(255) rescue nil),
    #       search_keyword: (@@referrer_parser.parse(@referrer)[:term].first(255) rescue nil).presence
    #   }
    # end

    def tech_properties
      client = DeviceDetector.new(self.user_agent)
      device_type =
          case client.device_type
          when 'smartphone'
            'Mobile'
          when 'tv'
            'TV'
          else
            client.device_type.try(:titleize)
          end
      {
          device: self.device,
          browser: client.name,
          os: client.os_name,
          device_type: device_type
      }
    end

    def request_properties
      {
          ip: self.remote_ip,
          user_agent: self.user_agent,
          referrer: self.referrer,
          landing_page: self.landing_page,
          platform: self.platform,
          app_version: self.app_version,
          os_version: self.os_version,
          screen_height: self.screen_height,
          screen_width: self.screen_width,
          company_id: self.company_id,
          user_id: self.user_id,
          started_at: self.started_at
      }
    end

  end

end