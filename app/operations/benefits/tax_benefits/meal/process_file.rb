class Benefits::TaxBenefits::Meal::ProcessFile < Benefits::TaxBenefits::Meal::Base
  attr_accessor :file, :parsed_data, :response_presenter

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:file].blank?
      add_message :error, 'Error loading file. File not uploaded correctly'
      return
    end
  end

  def init
    self.file = params[:file]
    self.parsed_data = ImportUtil.load_spreadsheet(file, [:user, :amount])
  end

  def validate
    if parsed_data.blank?
      add_message :error, 'Nothing to process'
    end
  end

  def process
    params[:payment_order] = self.parsed_data
    params[:card_program_id] = CardProgram.id_for(:meal)
    self.response_presenter = Benefits::TaxBenefits::Process.(user, params)
  end

  def success
    self.response_presenter
  end

  def failure
    self.response_presenter
  end

end