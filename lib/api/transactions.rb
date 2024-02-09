require "./config/database"
require "./lib/models/transaction"

module Api
  module Transactions
    def self.registered(app)
      app.helpers do
        def validate_transaction_request!
          # TODO: Improve with specific messages for each validation rule broken
          validations = {
            "valor" => ->(value) { !value.nil? },
            "tipo" => ->(value) { !value.nil? && !value.empty? && (value == "c" || value == "d") },
            "descricao" => ->(value) { !value.nil? && value.size >= 1 && value.size <= 10 },
          }

          validations.each do |(key, validation)|
            halt 400, { message: "Invalid #{key}" }.to_json unless validation.call(request_body[key])
          end
        end
      end

      app.post "/clientes/:id/transacoes" do
        validate_transaction_request!
        validate_current_client!

        result = Database.with_advisory_lock(current_client[:id]) do
          transaction_creation = Models::Transaction.create(
            value: request_body["valor"],
            type: request_body["tipo"],
            description: request_body["descricao"],
            client_id: current_client[:id],
          )

          if transaction_creation[:success]
            {
              success: true,
              balance: current_client.calculate_balance,
            }
          else
            {
              success: false,
              message: transaction_creation[:message],
            }
          end
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
