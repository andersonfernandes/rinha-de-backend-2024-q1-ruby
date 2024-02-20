require "./lib/adapters/database"

module Services
  class Transaction
    def initialize(client_id:, transaction_params:, on_success:, on_fail:)
      @client_id = client_id
      @transaction_params = transaction_params
      @on_success = on_success
      @on_fail = on_fail
    end

    def self.call(args)
      new(**args).process_transaction
    end

    def process_transaction
      Database.connection.transaction do
        client = Database.connection["SELECT * FROM clients WHERE id=:id FOR UPDATE", id: client_id].first
        return on_fail.call(404) unless client

        value, type, description = transaction_params.values_at(:value, :type, :description)
        balance = client[:current_balance]
        inconsistent_balance = type == "d" && (balance - value) < (client[:limit] * -1)

        return on_fail.call(422) if inconsistent_balance

        Database.connection[
          "INSERT INTO transactions (value, type, description, client_id) VALUES(:value, :type, :description, :client_id)",
          value: value,
          type: type,
          description: description,
          client_id: client_id
        ].first

        updated_value = client[:current_balance] + (type == "d" ? value * -1 : value)
        updated_client = Database.connection[
          'UPDATE clients SET current_balance=:updated_value WHERE id=:id RETURNING "limit", "current_balance"',
          updated_value: updated_value,
          id: client_id
        ].first

        on_success.call(updated_client)
      end
    end

    private

    attr_reader :client_id, :transaction_params, :on_success, :on_fail
  end
end
