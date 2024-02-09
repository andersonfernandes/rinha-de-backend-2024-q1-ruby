module Models
  class Transaction < Sequel::Model
    def self.create(value:, type:, description:, client_id:)
      client = Models::Client[client_id]
      current_balance = client.calculate_balance

      current_balance += value if type == "c"
      current_balance -= value if type == "d"

      return {
               success: false,
               message: "The transaction value is higher than the client limit",
             } if current_balance < (client[:limit] * -1)

      transaction = Models::Transaction.insert(
        value: value,
        type: type,
        description: description,
        client_id: client_id,
        at: Time.now,
      )

      {
        success: true,
        transaction: transaction,
      }
    end
  end
end
