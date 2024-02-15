module Api
  module Statements
    def self.registered(app)
      app.get "/clientes/:id/extrato" do
        Database.connection.transaction do |connection|
          client_sql = 'SELECT "current_balance", "limit" FROM "clients" WHERE "id"=$1 LIMIT 1 FOR UPDATE'
          client = connection.exec_params(client_sql, [params[:id].to_i]).first
          return not_found unless client

          transactions_sql = 'SELECT * FROM "transactions" WHERE "client_id"=$1 ORDER BY "at" DESC LIMIT 10 FOR UPDATE'
          transactions = connection.exec_params(transactions_sql, [params[:id].to_i])

          {
            saldo: {
              total: client["current_balance"],
              data_extrato: Time.now.to_s,
              limite: client["limit"],
            },
            ultimas_transacoes: transactions.map do |transaction|
              {
                valor: transaction["value"],
                tipo: transaction["type"],
                descricao: transaction["description"],
                realizada_em: transaction["at"],
              }
            end,
          }.to_json
        end
      end
    end
  end
end
