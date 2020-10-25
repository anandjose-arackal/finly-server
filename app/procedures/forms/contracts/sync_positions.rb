require 'reform/form/dry'
class Forms::Contracts::SyncPositions < Reform::Form

  feature Reform::Form::Dry # override the default activemodel validation
end