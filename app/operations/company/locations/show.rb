class Company::Locations::Show < Company::Locations::Base

  def init
    super
    id = params[:id] || params[:location_id]
    self.location = self.company.locations.find_by id: id
  end

  def validate
    if self.location.blank?
      add_message :error, "Cannnot find Location"
    end
  end

  def process

  end

  def success
    params[:location] = self.location
    Company::Locations::Show::ShowPresenter.new(user, params, messages)
  end


  class Company::Locations::Show::ShowPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :location, :states

    def init
      self.location = params[:location]
      self.states = State.select(:id, :name)
    end
  end

end