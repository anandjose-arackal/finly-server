class Receipt::ReceiptEmails::Extractor::Adapter::DataPoint
  attr_accessor :mode, :xpath, :xpath_regex, :css_selector, :css_selector_regex

  def self.xpath_mode(xpath, regex)
    self.new(:xpath, xpath, regex, nil, nil)
  end

  def self.css_selector_mode(css_selector, regex)
    self.new(:css_selector, nil, nil, css_selector, regex)
  end

  def initialize(mode, xpath, xpath_regex, css_selector, css_selector_regex)
    self.mode = mode
    self.xpath = xpath
    xpath_regex = Regexp.new xpath_regex if xpath_regex.is_a?(String)
    self.xpath_regex = xpath_regex
    self.css_selector = css_selector
    css_selector_regex = Regexp.new css_selector_regex if css_selector_regex.is_a?(String)
    self.css_selector_regex = css_selector_regex
  end

  def extract_data_from(parser)
    case mode
      when :xpath
        # Gsubbing removes the comma from the amounts if any is found
        return (parser&.xpath(xpath)&.text[xpath_regex].gsub(',','') rescue nil)
      when :css_selector
        # Gsubbing removes the comma from the amounts if any is found
        return (parser&.at_css(css_selector)&.text[css_selector_regex].gsub(',','') rescue nil)
    end
  end

end
