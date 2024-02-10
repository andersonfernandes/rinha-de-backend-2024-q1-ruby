require "./lib/models/transaction"

module Api
  module Statements
    def self.registered(app)
      app.get "/clientes/:id/extrato" do
        validate_current_client!

        transactions = Models::Transaction.where(client_id: current_client[:id]).order(Sequel.desc(:id)).limit(10)
        {
          saldo: {
            total: current_client.current_balance,
            data_extrato: Time.now.to_s,
            limite: current_client[:limit],
          },
          ultimas_transacoes: transactions.map do |transaction|
            {
              valor: transaction.value,
              tipo: transaction.type,
              descricao: transaction.description,
              realizada_em: transaction.at,
            }
          end,
        }.to_json
      end
    end
  end
end
