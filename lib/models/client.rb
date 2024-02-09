module Models
  class Client < Sequel::Model
    def calculate_balance
      transactions = Models::Transaction.where(client_id: self[:id]).order(:id)

      transactions.reduce(self[:initial_balance]) do |balance, transaction|
        balance += transaction[:value] if transaction[:type] == "c"
        balance -= transaction[:value] if transaction[:type] == "d"

        balance
      end
    end
  end
end
