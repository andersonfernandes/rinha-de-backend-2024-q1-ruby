module Models
  class Transaction < Sequel::Model
    def self.create(value:, type:, description:, client:)
      balance = client.current_balance
      return {
               success: false,
               message: "The transaction value is higher than the client limit",
             } if type == "d" && (balance -= value) < (client[:limit] * -1)

      transaction = self.insert(
        value: value,
        type: type,
        description: description,
        client_id: client.id,
        at: Time.now,
      )

      { success: true }
    end
  end
end
