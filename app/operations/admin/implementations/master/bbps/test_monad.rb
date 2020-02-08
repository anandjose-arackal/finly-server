require 'dry/monads'
require 'dry/monads/do'
class Admin::Implementations::Master::Bbps::TestMonad
  include Dry::Monads[:result]
  include Dry::Monads::Do.for(:call)

  def call(params)
    user = yield find_user(params)
    amount = yield find_amount(params)

    Success(amount)
  end

  def find_user(params)
    if params[:user]
      return Success(params[:user])
    end
    Failure(:missing_user)
  end

  def find_amount(params)
    if params[:amount]
      return Success(params[:amount])
    end
    Failure(:missing_amount)
  end

end