class HardWorker
  include Sidekiq::Worker
  def perform(start_url, search_phrase, id)
    @sp = SearchProgram.new(start_url, search_phrase, id)
    @sp.run
  end
end