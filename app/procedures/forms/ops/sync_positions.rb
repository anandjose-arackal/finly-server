class Forms::Ops::SyncPositions < Transactions::API

  schema do
    params do
      required(:id).filled
    end
  end

  step Model(Form, :find_by_uuid)

  # step Policy::Pundit(Forms::Entities::Policy, :sync_position?)

  step :check_success

  step Contract::Build(builder: :build_contract!)

  step Contract::Validate(key: :form)

  step Contract::Persist()

  step Transactions::Messages::SuccessMessage('Saved Form Fields with Positions')

  fail :check_failure

  # Helper methods
  def check_success(ctx, options)
    true
  end

  def check_failure(ctx, options)
    true
  end

  def build_contract!(options, model:, current_user:, **)

    dynamic_contract = Class.new(Forms::Contracts::SyncPositions) do

      model.sections.each do |section|
        collection :sections do
          property :id
          collection :entities do
            property :id
            property :position

            validation :unique_positions do
              params do
                required(:position).filled
              end
            end
          end
        end
      end
    end

    dynamic_contract.new(model, current_user: current_user)
  end

end