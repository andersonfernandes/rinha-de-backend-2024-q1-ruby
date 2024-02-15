require "./config/database"

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
        Database.connection.transaction do |connection|
          validate_transaction_request!

          connection.exec_params("SELECT pg_advisory_xact_lock($1)", [params[:id].to_i])
          client_sql = 'SELECT "current_balance", "limit" FROM "clients" WHERE "id"=$1 LIMIT 1'
          client = connection.exec_params(client_sql, [params[:id].to_i]).first
          return not_found unless client

          value, type, description = request_body.values_at("valor", "tipo", "descricao")

          return halt(422) if type == "d" && (client["current_balance"] - value) < (client["limit"] * -1)

          sql = <<-SQL
            WITH transaction AS (
              INSERT INTO "transactions" ("value", "type", "description", "client_id", "at")
              VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)
            )

            UPDATE "clients"
            SET "current_balance" = "clients"."current_balance" +
                                  (SELECT CASE WHEN $2 = 'd' THEN $1 * -1 ELSE $1 END)
            WHERE "clients"."id" = $4
            RETURNING current_balance
          SQL

          result = connection.exec_params(sql, [value, type, description, params[:id].to_i]).first

          {
            limite: client["limit"],
            saldo: result["current_balance"],
          }.to_json
        end
      end
    end
  end
end
