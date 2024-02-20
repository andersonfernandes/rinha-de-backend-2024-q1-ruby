require "sequel"
require "logger"

module Database
  def self.init!
    return if @connection

    @connection ||= Sequel.connect(
      ENV["DATABASE_URL"],
      logger: Logger.new(STDOUT),
      max_connections: ENV.fetch("MAX_DATABASE_CONNECTIONS", 5),
    )
    @connection.sql_log_level = ENV["RACK_ENV"] == "development" ? :debug : :info

    @connection
  end

  def self.connection
    init!

    @connection
  end
end
