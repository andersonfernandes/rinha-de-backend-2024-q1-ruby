require "./lib/services/statement"

module Api
  module Statements
    def self.registered(app)
      app.get "/clientes/:id/extrato" do
        Services::Statement.call(
          client_id: params[:id].to_i,
          on_success: lambda do |(client, transactions)|
            return {
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
          end,
          on_fail: lambda do |error_code|
            return halt(error_code)
          end,
        )
      end
    end
  end
end
