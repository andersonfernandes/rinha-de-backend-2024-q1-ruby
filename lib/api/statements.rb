require "./lib/models/transaction"
require "./lib/models/client"

module Api
  module Statements
    def self.registered(app)
      app.get "/clientes/:id/extrato" do
        client = Models::Client.eager(:last_transactions).where(id: params[:id]).first
        set_current_client(client)
        validate_current_client!

        {
          saldo: {
            total: current_client[:current_balance],
            data_extrato: Time.now.to_s,
            limite: current_client[:limit],
          },
          ultimas_transacoes: client.last_transactions.map do |transaction|
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
