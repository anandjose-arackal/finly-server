class Benefits::BaseController < ApplicationController


  before_action -> { finly_authorize! :web}

  def process_file
    @result = Benefits::TaxBenefits::ParseFile.(cards_config, current_user, params)
    respond
  end

  def create
    @result = Benefits::TaxBenefits::Create.(cards_config, current_user, params)
    respond
  end

  def update
    @result = Benefits::TaxBenefits::Update.(cards_config, current_user, params)
    if @result.success?
      respond_to do |format|
        format.json { render 'benefits/base/process_file' }
        format.html {}
      end
      return
    end
    respond
  end

  def index
    @result = Benefits::TaxBenefits::Index.(cards_config, current_user, params)
    respond
  end

  def show
    @result = Benefits::TaxBenefits::Show.(cards_config, current_user, params)
    respond
  end

  def destroy
    @result = Benefits::TaxBenefits::Cancel.(cards_config, current_user, params)
    respond response: @result.success? ? :success : :failure
  end

  protected
  def cards_config

  end

end
