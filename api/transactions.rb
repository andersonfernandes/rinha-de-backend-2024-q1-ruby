module Api
  module Transactions
    def self.registered(app)
      app.helpers do
        def validate_transaction_request!
          # TODO: Improve with specific messages for each validation rule broken
          validations = {
            "valor" => ->(value) { !value.nil? },
            "tipo" => ->(value) { !value.nil? && !value.empty? && (value == "c" || value == "d") },
            "descricao" => ->(value) { !value.nil? && value.size >= 1 && value.size <= 10 },
          }

          validations.each do |(key, validation)|
            halt 400, { message: "Invalid #{key}" }.to_json unless validation.call(request_body[key])
          end
        end
      end

      app.post "/clientes/:id/transacoes" do
        validate_transaction_request!
        validate_current_client!

        # TODO: implement transaction logic

        request_body.to_json
      end
    end
  end
end
