class Appsmith::Companies:: VirtualBankAccounts::Policy < ApplicationPolicy

    def create?
      user.admin?
    end
    

end
