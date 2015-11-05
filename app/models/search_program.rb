class SearchProgram < ActiveRecord::Base
 attr_accessor :search_model, :url, :search, :valid_initial_url, :valid_link_index, :search_counter, :found_search, :raw_html, :links_on_page, :previous_choices, :original_url
  
  def initialize(start_url, search_phrase, id)
    @search_id = id
    
    @url = "/wiki/" + start_url
    @original_url = "/wiki/" + start_url
    @search = search_phrase
    
    @valid_initial_url = true
    @valid_link_index = nil
    
    @search_counter = 0
    
    @found_search = false
    
    @raw_html = nil
    
    @links_on_page = []
    @previous_choices = []

  end
  
  def run
    
    until @search_counter > 500 || @valid_initial_url == false
      get_raw_html
      break if @valid_initial_url == false
      create_site
      search_page
      break if @found_search
      parse_html
      get_valid_link
      select_new_link
    end
    
    if @valid_initial_url == false #sets all the parameters in the model on a completed search, i can refactor this but cba atm
      puts "invalid link" 
      search = Search.where(id: @search_id)[0]
      search.failed = true
      search.save
    end

    if @found_search == true
      search = Search.where(id: @search_id)[0]
      search.found_result = true
      search.save
    end
    
     search = Search.where(id: @search_id)[0]
     search.finished = true
     search.save
    
  end
  
  
  def get_raw_html
    begin
      @raw_html = Nokogiri::HTML(open("https://en.wikipedia.org" + @url))
    rescue
      @valid_initial_url = false #saves it from an error if the url is invalid
    end
    puts @search_counter.to_s + "|" + @url
  end
  
  def create_site
    Search.where(id: @search_id)[0].sites.create(url: @url)
  end
  

  def search_page
    page_text = @raw_html.xpath("//p//text()", "//a//text()", "//h1//text()", "//h2//text()", "//h3//text()", "//h4//text()", "//span//text()")
    @found_search = page_text.to_s.downcase.include?(@search.downcase)
    puts "found -" + @search + "- on -" + @url + "-" if @found_search
  end

  
  def parse_html
    
    @links_on_page = @raw_html.xpath("//a").to_s.split("><") #splits links
    
    @links_on_page.each_with_index do |link, index| #repairs the links, need to do this so that the 3rd letter is "h" so it's a good link
        @links_on_page[index] = "<" + link unless link[0] == "<" 
        @links_on_page[index] << ">" unless link[-1] == ">"
    end
    
  end
  
  
  def get_valid_link
    
    @valid_link_index = nil #will remain nil if a valid link isn't found
    
    
    @links_on_page.each_with_index do |link, index|
      is_valid_link = true
      
      @previous_choices.include?(link) ? is_valid_link = false : @previous_choices << link # will check if the previous results arr
      #contains the current link
      
      if is_valid_link #won't run if it's already established the link is invalid
        unless link.include?("wiki") && !(link.include?('upload.')) && !(link.include?('commons.'))  && !(link.include?('google.com')) && !(link[3] == "c") && !(link.include?('class="image"')) && !(link.include?('disambiguation')) && !(link.include?(':')) && !(link.include?('#')) && !(link.include?('img'))
          is_valid_link = false
        end
      end
       
      @valid_link_index = index if is_valid_link #will save the index of the link if it's valid
      
      break if is_valid_link #will break if the link is found or if it's cycled through 100 links
      
    end


  end
  
  
  def select_new_link
    
    if @valid_link_index.nil? #selects ethier a new link or the first one depending on what the @valid_link_index is
      @url = @original_url
      puts "RETURNING"
    else
      new_link = @links_on_page[@valid_link_index]
      new_link = new_link.split('href="')[1]
      @url = new_link.split('" title=')[0]
    end
    
    
    
    @search_counter +=1
  end

end
