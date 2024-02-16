require "./config/database"
require "./lib/models/transaction"

module Models
  class Client < Sequel::Model
  end

  Client.one_to_many :last_transactions, class: Models::Transaction, order: Sequel.desc(:at), limit: 10
end
