class Admin::Cards::Import < Admin::Base

  attr_accessor :file_url, :file, :result_hash, :params, :missing_params, :sheet, :header, :card_params

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters. please try again"
    end
  end

  def init
    self.file = params[:file]
    self.result_hash = {}
    if file.present?
      self.sheet = ImportUtil.open_spreadsheet(file)
      self.header = sheet.row(1)
    end
  end

  def validate
    if file.nil? || sheet.nil?
      add_message :error, "No file uploaded, please attach a file and try again"
    end
  end

  def process
    (2..sheet.last_row).each do |i|
      row = sheet.row(i)
      self.card_params = process_row(row)

      unless validate_params(row)
        result_hash[i] = "#{missing_params.to_sentence} cannot be blank"
        next
      end

      card = Card.new(card_params)
      if card.save
        card.update(active: true)
        result_hash[i] = "Success!"
      else
        add_message :error, card.errors.full_messages
      end
    end
  end

  def post_process
    self.file_url = create_response_csv
  end

  def success
    params[:file_url] = file_url
    Admin::Cards::Import::FilePresenter.new(user, params, messages)
  end

  class Admin::Cards::Import::FilePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :file_url

    def init
      self.file_url = params[:file_url]
    end
  end

  private

  def process_row(row)
    card_proxy = row[import_fields[:proxy]].to_s
    card_program_id = row[import_fields[:card_program_id]].to_i.to_s
    itz_cash_card_program_id = row[import_fields[:itz_cash_card_program_id]].to_i.to_s
    company_id = row[import_fields[:company_id]].to_i.to_s
    ending_number = row[import_fields[:ending_number]].to_i.to_s

    params = {

        proxy: card_proxy,
        card_program_id: card_program_id,
        itz_cash_card_program_id: itz_cash_card_program_id,
        company_id: company_id,
        ending_number: ending_number,
        card_status_id: CardStatus.id_for(:unassigned)

    }
  end

  def import_fields
    {
        :proxy => 0,
        :company_id => 1,
        :card_program_id => 2,
        :itz_cash_card_program_id => 3,
        :ending_number => 4
    }
  end

  def validate_params(row)
    self.missing_params = []
    if row[import_fields[:proxy]].blank?
      missing_params << "Card Serial No."
    end
    if row[import_fields[:company_id]].blank?
      missing_params << "Company ID"
    end
    if row[import_fields[:itz_cash_card_program_id]].blank?
      missing_params << "ItzCash Card Program"
    end
    if row[import_fields[:card_program_id]].blank?
      missing_params << "Card Program"
    end
    missing_params
  end

  def create_response_csv
    file_name = "public/common/files/temp_files/#{DateUtils.local_date_time}-#{user.id}-result.csv".gsub(Regexp.union([' ', '-', ':', '+']), '')
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