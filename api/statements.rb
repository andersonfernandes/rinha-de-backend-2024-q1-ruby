module Api
  module Statements
    def self.registered app
      app.get '/clientes/:id/extrato' do
        'extrato'
      end
    end
  end
end