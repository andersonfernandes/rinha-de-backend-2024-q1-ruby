require "./config/database"
require "./lib/models/transaction"

module Api
  module Transactions
    def self.registered(app)
      app.helpers do
        def validate_transaction_request!
          validations = {
            "valor" => ->(value) { !value.nil? && value.kind_of?(Integer) },
            "tipo" => ->(value) { !value.nil? && !value.empty? && (value == "c" || value == "d") },
            "descricao" => ->(value) { !value.nil? && value.size >= 1 && value.size <= 10 },
          }

          validations.each do |(key, validation)|
            halt 422, { message: "Invalid #{key}" }.to_json unless validation.call(request_body[key])
          end
        end
      end

      app.post "/clientes/:id/transacoes" do
        validate_transaction_request!
        validate_current_client!

        result = Database.with_advisory_lock(current_client[:id]) do
          success, message = Models::Transaction.create(
            value: request_body["valor"],
            type: request_body["tipo"],
            description: request_body["descricao"],
            client: current_client,
          ).values_at(:success, :message)

          if success
            value = request_body["tipo"] == "d" ? request_body["valor"] * -1 : request_body["valor"]
            current_client.update_balance!(value)
          end

          {
            success: success,
            message: message,
            balance: success ? current_client.current_balance : nil,
          }
        end

        if (!result[:success])
          halt 422, { message: result[:message] }.to_json
        end

        {
          limite: current_client[:limit],
          saldo: result[:balance],
        }.to_json
      end
    end
  end
end
