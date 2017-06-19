class Receipt::ReceiptEmails::Extractor::Adapter::DataPoint
  attr_accessor :mode, :xpath, :xpath_regex, :css_selector, :css_selector_regex, :options

  def self.xpath_mode(xpath, options={})
    self.new(:xpath, xpath, nil, options)
  end

  def self.css_selector_mode(css_selector, options = {})
    self.new(:css_selector, nil, css_selector, options)
  end

  def initialize(mode, xpath, css_selector, options = {})
    self.mode = mode
    options = {} unless options.is_a?(Hash) and options.present?

    self.xpath = xpath
    self.xpath_regex = (options[:xpath_regex] or Receipt::ReceiptEmails::Extractor::Adapter::Base::REGEX_AMOUNT)
    self.xpath_regex = Regexp.new xpath_regex if xpath_regex.is_a?(String)

    self.css_selector = css_selector
    self.css_selector_regex = (options[:css_selector_regex] or Receipt::ReceiptEmails::Extractor::Adapter::Base::REGEX_AMOUNT)
    self.css_selector_regex = Regexp.new css_selector_regex if css_selector_regex.is_a?(String)

    self.options = options
  end

  def extract_data_from(parser)
    extract = nil
    regex = nil
    case mode
      when :xpath
        # Gsubbing removes the comma from the amounts if any is found
        extract = parser&.xpath(xpath)
        regex = xpath_regex
      when :css_selector
        # Gsubbing removes the comma from the amounts if any is found
        extract = parser&.css(css_selector)
        regex = css_selector_regex
      else
        return nil
    end
    extract = process_options extract
    extract&.text[regex].gsub(',', '') rescue nil
  end

  # Allows defining options such as position of array after xpath / css_selector is applied
  def process_options(extract)
    return extract unless extract.present?
    return unless [Nokogiri::XML::NodeSet].include?(extract.class)
    # Default css selector is considered at first position unless position is defined
    case self.options[:position]
      when :first, nil
        return extract.first
      when :last
        return extract.last
    end

    extract
  end

end
