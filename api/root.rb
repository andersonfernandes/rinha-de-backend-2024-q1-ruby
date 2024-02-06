require './api/statements'
require './api/transactions'

module Api
  module Root
    def self.registered app
      app.register Statements
      app.register Transactions
    end
  end
end