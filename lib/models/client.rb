require "./config/database"

module Models
  class Client < Sequel::Model
    def update_balance!(value)
      self.update(current_balance: self.current_balance + value)
    end
  end
end
