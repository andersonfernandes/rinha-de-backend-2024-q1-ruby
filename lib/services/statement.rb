require "./lib/adapters/database"

module Services
  class Statement
    def initialize(client_id:, on_success:, on_fail:)
      @client_id = client_id
      @on_success = on_success
      @on_fail = on_fail
    end

    def self.call(args)
      new(**args).statement
    end

    def statement
      client = Database.connection["SELECT * FROM clients WHERE id=:id FOR UPDATE", id: client_id].first
      return on_fail.call(404) unless client

      transactions = Database.connection[
        "SELECT * FROM transactions WHERE client_id=:id ORDER BY at desc LIMIT 10",
        id: client_id
      ].all

      on_success.call([client, transactions])
    end

    private

    attr_reader :client_id, :on_success, :on_fail
  end
end
