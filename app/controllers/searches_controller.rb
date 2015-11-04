require 'nokogiri'
require 'open-uri'

class SearchesController < ApplicationController
  respond_to :html, :js
  
  def new
    @search = Search.new
  end
  
  def create
    @search = Search.create(search_params)
    LogJob.new.async.perform(@search.start_url, @search.search_phrase, @search.id)
    #HardWorker.perform_async(@search.start_url, @search.search_phrase, @search.id)
    redirect_to @search
  end
  
  def show
    @search = Search.find(params[:id])
  end
  
  def index
    @searches = Search.all
  end
  
  private

  def search_params
    params.require(:search).permit(:search_phrase, :start_url)
  end
  
end
