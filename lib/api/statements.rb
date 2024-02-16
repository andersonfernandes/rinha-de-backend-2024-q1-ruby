module Api
  module Statements
    def self.registered(app)
      app.get "/clientes/:id/extrato" do
        Database.connection.transaction do
          client = Database.connection["SELECT * FROM clients WHERE id=:id FOR UPDATE", id: params[:id].to_i].first
          return not_found unless client

          transactions = Database.connection[
            "SELECT * FROM transactions WHERE client_id=:id ORDER BY at desc LIMIT 10 FOR UPDATE",
            id: params[:id].to_i
          ].all

          {
            saldo: {
              total: client[:current_balance],
              data_extrato: Time.now.to_s,
              limite: client[:limit],
            },
            ultimas_transacoes: transactions.map do |transaction|
              {
                valor: transaction[:value],
                tipo: transaction[:type],
                descricao: transaction[:description],
                realizada_em: transaction[:at],
              }
            end,
          }.to_json
        end
      end
    end
  end
end
