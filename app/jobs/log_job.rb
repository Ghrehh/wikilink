class LogJob
  include SuckerPunch::Job

  def perform(start_url, search_phrase, id)
    @sp = SearchProgram.new(start_url, search_phrase, id).run
  end
end