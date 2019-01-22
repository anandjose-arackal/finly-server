class Admin::Cards::BulkAssign < Admin::Base

  attr_accessor :file, :result_hash, :sheet, :header, :content, :response

  def init
    self.file = params[:file]
    self.result_hash = {}
    self.sheet = ImportUtil.open_spreadsheet(file)
    self.header = sheet.row(1)
  end

  def validate
    # validating presence of
    (2..sheet.last_row).each do |i|
      row = sheet.row(i)
      # validating presence of various attributes
      if mobile_number_blank?(row)
        result_hash[i] = 1
        next
      end
      if card_type_blank?(row)
        result_hash[i] = 2
        next
      end
      if card_serial_blank?(row)
        result_hash[i] = 3
        next
      end
    end
  end

  def process
    (2..sheet.last_row).each do |i|
      row = sheet.row(i)
      if result_hash[i].present?
        case result_hash[i]
          when 1
            # i.e. the mobile number is blank
            result_hash[i] = "Mobile Number cannot be blank"
          when 2
            # i.e. card type is blank
            result_hash[i] = "Card Type cannot be blank"
          when 3
            result_hash[i] = "Card Serial cannot be blank"
          else
            # do nothing?
        end
      end

      mobile_number = row[import_fields[:mobile_number]]
      card_serial = row[import_fields[:card_serial]]
      card_type = row[import_fields[:card_type]]

      if [1, 2, 3, 4, 5].include?(card_type)
        result_hash[i] = "Invalid card type. Try again"
        next
      end

      # finding the user against whom to add this particular card
      user = User.find_by mobile_number: mobile_number

      # checking if the user is present in Finly
      if user.blank?
        result_hash[i] = "User not found"
        next
      end

      # checking if the user already has an existing card of the same type already
      if user.cards.with_card_program(card_type).present?
        result_hash[i] = "User already has a card of this type"
        next
      end

      card = user.cards.build(proxy: card_serial, ending_number: "1234", card_program_id: card_type, itz_cash_card_program_id: 17, company_id: user.company_id, card_status_id: CardStatus.id_for(:assigned))

      unless card.save
        result_hash[i] = card.errors.full_messages.to_sentence
      end
    end
  end

  def post_process
    self.header = [
        "mobile_number".humanize,
        "card_serial".humanize,
        "card_type".humanize
    ]

    self.content = []
    (2..sheet.last_row).each do |i|
      self.content << sheet.row(i)
      self.content[i-2] << self.result_hash[i]
    end
  end

  def success
    # generaing response CSV
    self.response = Exporter.new(user, {spreadsheet: {headers: self.headers, contents: self.content}}, messages)
  end

  private

  def import_fields
    {
        :mobile_number => 1,
        :card_serial => 2,
        :card_type => 3
    }
  end

  def mobile_number_blank?(row)
    if row[import_fields[:mobile_number]].blank?
      return true
    end
    false
  end

  def card_type_blank? (row)
    if row[import_fields[:card_type]].blank?
      return true
    end
    false
  end

  def card_serial_blank?(row)
    if row[import_fields[:card_serial]].blank?
      return true
    end
    false
  end
end