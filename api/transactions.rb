module Api
  module Transactions
    def self.registered app
      app.post '/clientes/:id/transacoes' do
        'transacoes'
      end
    end
  end
end