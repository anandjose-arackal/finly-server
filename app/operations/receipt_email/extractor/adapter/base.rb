class ReceiptEmail::Extractor::Adapter::Base < BaseOperation
  attr_accessor :receipt_email, :parser, :html_body, :extracted_data

  def self.senders
    []
  end

  def self.mail_keywords
    []
  end

  def self.call(receipt_email, html_body)
    self.new(receipt_email, html_body).run
  end

  def initialize(receipt_email, html_body)
    self.receipt_email = receipt_email
    self.html_body = html_body
  end

  def pre_validate
    if self.receipt_email.blank?
      add_message :error, 'Receipt Email not found'
      return
    end
    if self.html_body.blank?
      add_message :error, 'Email not found'
      return
    end
  end

  def init
    self.parser = Nokogiri::HTML(html_body)
  end

  def validate
    if self.parser.blank?
      add_message :error, 'Error loading configuration'
      return
    end
  end

  def merchant

  end

  def amount_data_points

  end

  def amount_value
    data_points = amount_data_points
    return nil if data_points.blank?
    data_points = [data_points] unless data_points.is_a?(Array)
    data_points.each do |data_point|
      next unless data_point.is_a?(ReceiptEmail::Extractor::Adapter::DataPoint)
      amount_val = data_point.extract_data_from(self.parser)
      return amount_val if amount_val.present?
    end
  end

  def currency_id
    Currency.first.id
  end

  def datetime
    self.receipt_email.sent_at
  end

  def note
    self.receipt_email.subject
  end

  def category_id
    categories = self.receipt_email.user.company.categories
    categories.others&.first or categories.last.id
  end

  def status(merchant, amount_value, currency_id, datetime, note, category_id)
    unless merchant and amount_value and currency_id and datetime and note and category_id
      return ExpenseDataExtractStatus.id_for(:failed)
    end
    ExpenseDataExtractStatus.id_for(:success)
  end

  def process
    merchant = self.merchant
    amount_value = self.amount_value
    currency_id = self.currency_id
    datetime = self.datetime
    note = self.note
    category_id = self.category_id
    status_id = self.status(merchant, amount_value, currency_id, datetime, note, category_id)
    self.extracted_data = ReceiptEmail::Extractor::Data.new(merchant, amount_value, currency_id, datetime, note, category_id, status_id)
  end

  def success
    ReceiptEmail::Extractor::Adapter::Base::SuccessPresenter.new(extracted_data: self.extracted_data)
  end

  class ReceiptEmail::Extractor::Adapter::Base::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :extracted_data, :receipt_email, :html_body

    def initialize(params)
      super(nil, params)
    end

    def init
      self.extracted_data = params[:extracted_data]
      self.receipt_email = params[:receipt_email]
      self.html_body = params[:html_body]
    end

  end

  private
  def validate_mode
    unless [:xpath_only, :css_selector_only, :xpath_first, :css_selector_first].include?(self.mode)
      add_message :error, 'Invalid Parsing Mode'
    end
  end

end