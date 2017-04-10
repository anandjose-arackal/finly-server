# this operation will return the respective permissions a particular user will have -
# eg. if the role is a transcriber, he/she will have permission to transcribe receipts,
# if a particular user is an admin, he/shw will have permission to do..... everything
#

class Admin::AdminRolePermissions::Show < Admin::AdminRolePermissions::Base

  def pre_validate

  end

  def init

  end

  def process
    if user.finly_admin?
      response = {
          views: {
              admin: {
                  menus: {
                      navbar: [
                          {
                              name: "Companies",
                              url: "companies"
                          },
                          {
                              name: "Users",
                              url: "users"
                          },
                          {
                              name: "Reports",
                              url: "reports"
                          },
                          {
                              name: "Expenses",
                              url: "expenses"
                          },
                          {
                              name: "Cards",
                              url: "cards"
                          }
                      ]
                  }
              }
          }
      }
    else
      response = {
          views: {
              admin: {
                  menus: {
                      navbar: [
                          {
                              name: "Untrascribed Receipts",
                              url: "untranscribed_receipts"
                          },
                          {
                              name: "Transcribed Receipts",
                              url: "trascribed_receipts"
                          }
                      ]
                  }
              }
          }
      }
    end

  end

  def success
    response
  end
end

