require "./models/client"
require "./models/transaction"

module Api
  module Statements
    def self.registered(app)
      app.get "/clientes/:id/extrato" do
        client = Models::Client[params[:id]]
        transactions = Models::Transaction.where(client_id: params[:id])

        {
          saldo: {
            total: 0, # TODO: implement calculation
            data_extrato: Time.now.to_s,
            limite: client[:limit],
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
