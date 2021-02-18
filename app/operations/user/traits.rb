class User::Traits < User::Base
  attr_accessor :traits

  def init
  end

  def validate
  end

  def process
    traits = Masters::Users::TraitPublishers::UserHandler.properties(user)

    feature_traits = Masters::Users::TraitPublishers::FeatureSubscriptionHandler.properties(user)

    self.traits = traits.merge(feature_traits)
  end

  def success
    params[:traits] = self.traits
    User::Traits::Presenter.new(self.user, params, messages)
  end

  protected

  class User::Traits::Presenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :traits

    def init
      self.traits = params[:traits]
    end
  end

end