class Disburse::Users::Create < Admin::Users::Create
  def pre_validate
    # Overriding admin user create operation's behaviour
  end
end