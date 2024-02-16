require "./lib/adapters/database"

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

        Database.with_advisory_lock(params[:id].to_i) do
          client = Database.connection["SELECT * FROM clients WHERE id=:id FOR UPDATE", id: params[:id].to_i].first
          return not_found unless client

          value, type, description = request_body.values_at("valor", "tipo", "descricao")

          inconsistent_balance = type == "d" && (client[:current_balance] - value) < (client[:limit] * -1)
          return halt(422) if inconsistent_balance

          Database.connection[
            "INSERT INTO transactions (value, type, description, client_id) VALUES(:value, :type, :description, :client_id)",
            value: value,
            type: type,
            description: description,
            client_id: params[:id].to_i
          ].first

          updated_value = client[:current_balance] + (type == "d" ? value * -1 : value)
          Database.connection[
            "UPDATE clients SET current_balance=:updated_value WHERE id=:id ",
            updated_value: updated_value,
            id: params[:id].to_i
          ].first

          {
            limite: client[:limit],
            saldo: client[:current_balance],
          }.to_json
        end
      end
    end
  end
end
