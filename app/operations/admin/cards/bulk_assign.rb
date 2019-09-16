class Admin::Cards::BulkAssign < Admin::Base

  attr_accessor :file_url,:file, :result_hash, :sheet, :header, :content, :response

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

      mobile_number = row[import_fields[:mobile_number]].to_i.to_s
      card_serial = row[import_fields[:card_serial]]
      card_type = row[import_fields[:card_type]].to_i

      if [1, 2, 3, 4, 5].exclude?(card_type)
        result_hash[i] = "Invalid card type. Try again"
        next
      end

      # finding the user against whom to add this particular card
      user = User.find_by mobile_number: mobile_number
      card = Card.find_by proxy: card_serial

      # checking if the user is present in Finly
      if user.blank?
        result_hash[i] = "User not found"
        next
      end

      # checking if the user already has an existing card of the same type already
      if user.cards.active.with_card_program(card_type).present?
        result_hash[i] = "User already has a card of this type"
        next
      end

      if card.blank?
        result_hash[i] = "Card not found"
        next
      end

      if user.present? && card.present?
        card.assign_attributes(user_id: user.id, card_status_id: CardStatus.id_for(:assigned))
        if card.save
          result_hash[i] = "Success!"
        else
          result_hash[i] = card.errors.full_messages.to_sentence
        end
      end
    end
  end

  def post_process
    self.file_url = create_response_csv
  end

  def success
    params[:file_url] = file_url
    Admin::Cards::BulkAssign::FilePresenter.new(user, params, messages)
  end

  class Admin::Cards::BulkAssign::FilePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :file_url

    def init
      self.file_url = params[:file_url]
    end
  end

  private

  def import_fields
    {
        :mobile_number => 0,
        :card_serial => 1,
        :card_type => 2
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

  def create_response_csv
    file_name = "public/common/files/temp_files/#{DateUtils.local_date_time}-#{user.id}-result.csv".gsub(Regexp.union([' ', '-', ':', '+']), '')
    FileUtils.mkdir_p "public/common/files/temp_files" unless  Dir.exist?("public/common/files/temp_files")
    CSV.open(file_name, 'wb') do |csv|
      self.header << 'Result'
      csv << header
      (2..sheet.last_row).each do |i|
        row = sheet.row(i)
        row = row.map(&:to_s)
        row << result_hash[i]
        csv << row
      end
    end
    return file_name.gsub('public', '')
  end

end