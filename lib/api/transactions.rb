require "./lib/services/transaction"

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

        Services::Transaction.call(
          client_id: params[:id].to_i,
          transaction_params: {
            value: request_body["valor"],
            type: request_body["tipo"],
            description: request_body["descricao"],
          },
          on_success: lambda do |client|
            return {
                     limite: client[:limit],
                     saldo: client[:current_balance],
                   }.to_json
          end,
          on_fail: lambda do |error_code|
            return halt(error_code)
          end,
        )
      end
    end
  end
end
