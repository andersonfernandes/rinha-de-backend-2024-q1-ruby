module Models
  class Transaction < Sequel::Model
    def self.create(value:, type:, description:, client_id:)
      Models::Transaction.insert(
        value: value,
        type: type,
        description: description,
        client_id: client_id,
        at: Time.now,
      )
    end
  end
end
