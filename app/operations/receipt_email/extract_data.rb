class ReceiptEmail::ExtractData < ReceiptEmail::Base
  attr_accessor :amount, :currency_id, :merchant, :datetime, :note, :expense_data_extract

  def process
    html_body =
        sender = self.receipt_email.sender
    self.datetime = self.receipt_email.sent_at
    self.note = self.receipt_email.subject

    if self.receipt_email.raw_html.present?
      html_body = self.receipt_email.raw_html
    elsif self.receipt_email.original_source.present?
      email = Mail.read_from_string(File.read(self.receipt_email.original_source.path))
      html_body = email.html_part.body.decoded
    end

    matched_template = nil
    receipt_email_sender = ReceiptEmailSender.having_email_id(sender)
    # If a match is found based on sender, use the template. This works fine when the email is directly picked up
    #
    # If a match is not found, check if the search_term provided ReceiptEmailSender is found,
    # if found use that to identify the template. Used when the email is forwarded to receipts@finly.io
    if receipt_email_sender.present?
      matched_template = receipt_email_sender.receipt_email_template
    else
      # String search to find sender
      ReceiptEmailSender.all.each do |s|
        if html_body.contains(s.search_term)
          matched_template = s.receipt_email_template
          break
        end
      end
    end
    extract_data_using_template(matched_template, html_body)
  end

  def post_process
    attributes = {
        amount_attributes:
            {
                value: amount,
                currency_id: currency_id
            },
        merchant: merchant,
        category_id: user.company.categories.last.id,
        datetime: datetime,
        note: self.note,
        expense_data_extract_source_id: ExpenseDataExtractSource.id_for(:auto_extract_email)
    }
    self.expense_data_extract = self.receipt_email.expense_data_extracts.create attributes
  end

  def success
    params[:expense_data_extract] = self.expense_data_extract
    params[:receipt_email] = self.receipt_email
    ReceiptEmail::ExtractData::ExtractedData.new(user, params, messages)
  end

  class ReceiptEmail::ExtractData::ExtractedData < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :receipt_email, :expense_data_extract

    def init
      self.receipt_email = params[:receipt_email]
      self.expense_data_extract = params[:expense_data_extract]
    end
  end

  protected
  def extract_data_using_template(template, html_body)
    return if template.blank?
    parser = Nokogiri::HTML(html_body)
    self.merchant = template.name
    self.amount = extract_amount(parser, template)
    self.currency_id = extract_currency(parser, template)
  end

  def extract_amount(parser, template)
    template.receipt_email_data_points.each do |data_point|
      if data_point.xpath_only_mode?(:amount)
        result = parser.xpath(data_point.amount_xpath)&.text[Regexp.new(data_point.amount_xpath_regex)]
        return result if result.present?
      elsif data_point.css_selector_only_mode?(:amount)
        result = parser.at_css(data_point.amount_css_selector)&.text[Regexp.new(data_point.amount_css_selector_regex)]
        return result if result.present?
      elsif data_point.xpath_first_mode?(:amount)
        # Todo
      elsif data_point.css_selector_first_mode?(:amount)
        # Todo
      end
    end
  end

  def extract_currency(parser, template)
    template.default_currency_id
  end

end