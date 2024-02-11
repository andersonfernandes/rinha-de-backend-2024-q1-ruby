require "./lib/models/client"
require "./lib/api/statements"
require "./lib/api/transactions"

module Api
  module Root
    def self.registered(app)
      app.helpers do
        def request_body
          @request_body ||= JSON.parse request.body.read
        end

        def set_current_client(client)
          @current_client = client
        end

        def current_client
          @current_client ||= Models::Client[params[:id]]
        end

        def validate_current_client!
          unless current_client
            halt 404, { message: "Could not find Client with id=#{params[:id]}" }.to_json
          end
        end
      end

      app.register Statements
      app.register Transactions
    end
  end
end
