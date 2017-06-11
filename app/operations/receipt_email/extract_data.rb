class ReceiptEmail::ExtractData < ReceiptEmail::Base

  def process
    html_body = nil
    sender = self.receipt_email.sender
    datetime = self.receipt_email.sent_at
    note = self.receipt_email.subject

    if self.receipt_email.raw_html.present?
      html_body = self.receipt_email.raw_html
    elsif self.receipt_email.original_source.present?
      email = Mail.read_from_string(File.read(self.receipt_email.original_source.path))
      html_body = email.html_part.body.decoded
    end

    matched_template = nil
    receipt_email_sender = ReceiptEmailSender.having_email_id(sender)
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
    extract_data_using_template(matched_template, html_body, datetime, note)
  end

  def extract_data_using_template(template, html_body, datetime, note)
    return if template.blank?
    parser = Nokogiri::HTML(html_body)
    merchant_name = template.name
    amount = extract_amount(parser, template)
    currency_id = extract_currency(parser, template)
    if amount.present?
      user.expenses.create(amount_attributes: {value: amount, currency_id: currency_id},
                           manual_expense_attributes: {merchant: merchant_name},
                           category_id: user.company.categories.last.id, expense_type_id: ExpenseType.id_for(:manual), date: datetime,
                           receipt_email: self.receipt_email, receipts: self.receipt_email.receipts)
    end
  end

  def extract_amount(parser, template)
    debugger
    template.receipt_email_data_points.each do |data_point|
      if data_point.xpath_only_mode?(:amount)
        result = parser.at_css(data_point.amount_xpath)&.text[Regexp.new(data_point.amount_xpath_regex)]
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