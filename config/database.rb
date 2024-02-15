require "connection_pool"
require "pg"

module Database
  def self.init!
    return if @pool

    pool_size = ENV.fetch("DATABASE_POOL_SIZE") { 5 }.to_i
    pool_timeout = ENV.fetch("DATABASE_POOL_TIMEOUT") { 350 }.to_i
    @pool ||= ConnectionPool.new(size: pool_size, timeout: pool_timeout) do
      PG.connect(ENV["DATABASE_URL"])
    end

    @pool
  end

  def self.connection
    init!

    connection = @pool.checkout
    connection.type_map_for_results = PG::BasicTypeMapForResults.new connection

    connection
  end
end
