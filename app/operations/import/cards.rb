class Import::Cards < Import::Base

  attr_accessor :card_params

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "No user or params passed."
    end
  end


  def init
    self.file = params[:file]
    self.result_hash = {}
    self.sheet = open_spreadsheet(file)
    self.header = sheet.row(1)
  end

  def authorize

  end

  def validate

  end

  def process
    (2..sheet.last_row).each do |i|
      row = sheet.row(i)
      type = retrieve_import_type(row)
      self.card_params = process_row(row)
      error_messages = card_params[:error_messages]
      card_params.delete(:error_messages)
      if type == 'email'
        u = self.user.company.users.find_by(email: row[:import_fields[:email]])
        card = u.cards.create(card_params)
      elsif type == 'mobile'
        u = self.user.company.users.find_by(mobile_number: row[:import_fields[:mobile_number]])
        card = u.cards.create(card_params)
      end

      if Card.exists?(card.id) and not error_messages
        result_hash[i] = "Card assigned!"
      else
        result_hash[i] = error_messages
      end
    end
  end

  def post_process
    # generating the success csv
    self.response = generate_response_csv
  end

  private

  def retrieve_import_type(row)
    if row[import_fields[:email]].present?
      return 'email'
    elsif row[import_fields[:mobile_number]].present?
      return 'mobile'
    else
      # default case is email
      return 'email'
    end
  end

  # generating the parameters that enable the user to be invited
  def process_row(row)
    errors = []

    # i.e. add cards only when the user
    if row[import_fields[:card_serial_id]].present?
      self.card_params = {proxy: row[import_fields[:card_serial_id]],
                           card_type_id: 1,
                           product_code: Constants::ItzCash::PRODUCT_CODE,
                           ending_number: row[import_fields[:card_serial_id]].last(4)
                          }
    else
      errors << "Card not found"
      card_params[:error_messages] = errors
    end
    return user_params
  end

  def import_fields
    {
        :email => 0,
        :mobile_number => 1,
        :card_serial_id => 2
    }
  end
end