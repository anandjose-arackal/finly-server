class Bbps::SubscriptionsController < ApplicationController
  def create
    result = Bbps::Subscriptions::Ops::Create.(params)
  end
end