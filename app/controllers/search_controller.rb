require 'nokogiri'
require 'httparty'
require 'watir'
require 'sentimental'


class SearchController < ApplicationController
	 	 include WatchlistHelper
	
	def index
		# set search word #
		if params[:searchword]
			security_name = params[:searchword]
			# for autorefresh #
			respond_to do |format|
		      format.html
		      format.js
		    end
		# display the users last watchlist item #    
		elsif user_signed_in? && current_user.watchlists.any?
			security_name = "#{current_user.watchlists.last.name}"	
		else
			security_name = "facebook"
		end
		
		# automated browsing #
		automated_browser(security_name)

	    if @parsed_page.css("div.live-quote-subtitle").text == "" 
	    	# parsed_page.css("div.live-quote-title").text == "Data not available" || @parsed_page.css('div.chartError').text == "Data not available"
	    	@browser.close
			redirect_to search_index_path , danger: "Results not found, Please retry your input." 
		else

		    # create company #
		    company_info(@parsed_page)

		    # create articles array #
		    company_articles(@parsed_page)

		    # redirect browser to company description #
		    browser_company_info
 
		    # redirect to twitter #
	
		    twitter(@company[:twitter])

		    # create sentiment from tweets #
		    sentimental(@tweets)

		    # Redirect browser to get logo #
		    browser_grab_images

		    # close automated browser #
		    @browser.close

		end
 	end

 	def brokers

 	end


	 def automated_browser(security_name)
		# herouku browser
 		opts = {
		    headless: true
		  }

		  if (chrome_bin = ENV.fetch('GOOGLE_CHROME_SHIM', nil))
		    opts.merge!( options: {binary: chrome_bin})
		  end 
		security_name = security_name
			@browser = Watir::Browser.new :chrome, opts 

			# local browsers
		 # @browser = Watir::Browser.new(:chrome)
			# local headless
 		# @browser = Watir::Browser.new :chrome, headless: true
 			
		@browser.window.maximize
	    @browser.goto("https://www.msn.com/en-my/money/")
	    @browser.text_field(id:"finance-autosuggest").set security_name 
	    @browser.send_keys :enter
	    sleep 0.5
		@parsed_page = Nokogiri::HTML(@browser.html)	
 	end

 
	def company_info(parsed_page)
		parsed_page = parsed_page
		company = {}
	    company = {
	      ticker: parsed_page.css("div.live-quote-subtitle").text.split.last,
	      company_name: parsed_page.css("div.live-quote-title").text.split.first,
	      twitter: parsed_page.css("div.live-quote-subtitle").text.split.last.insert(0,'$'),
	      price: parsed_page.css("div.live-quote-bottom-tile span").first.text,
	      change_percent: parsed_page.css("div.live-quote-bottom-tile div div:nth-child(2)")[0].text,
	      change_price: parsed_page.css("div.live-quote-bottom-tile div div:nth-child(1)")[0].text 
	    }
	    @company = company
	    @time = parsed_page.css("div.exchange-attribute span").first.text
	end

	def company_articles(parsed_page)
	 	articles = []
	    article = {}
	    news_links = parsed_page.css(".bingNewsContainer a")
	    #---- grab each articles -------#
	    news_links.each do |x|
	      article = {
	        body: x.css("h3").text,
	        link: x.attributes["href"].value,
	        source: x.css("span.sourcename").text,
	        timeframe: x.css("span.dt").text 
	        }
	      articles << article
	    end
		@articles = articles
	end

	def browser_company_info
 		url = "https://www.marketwatch.com/investing/stock/#{@company[:ticker]}/profile"
      	unparsed_page = HTTParty.get(url)
	  	parsed_page = Nokogiri::HTML(unparsed_page)
 		######### company description #########
 		@company_description = parsed_page.css('#maincontent div.full p').text
 		@company_sector = parsed_page.css('div.twowide div:nth-child(3) p.data').first.text
	end

	def twitter(security)
	  security = security
	  set_analyzer
	  ########## set page for scrape #################
	  url = "https://twitter.com/search?f=tweets&q=#{security}"
      unparsed_page = HTTParty.get(url)
	  parsed_page = Nokogiri::HTML(unparsed_page)
	  ########## create tweets array ################
	  tweets = parsed_page.css('div.tweet')
	  security_tweets = []
	  #---- grab each tweet -------#
	  tweets.each do |twat|
	    tweet = {
	    fullname: twat.css('strong.fullname').text,
	    username: twat.css('span.username').text,
	    when: twat.css('span.u-hiddenVisually').first.text,
	    content: twat.css('p.TweetTextSize').text,
	    avatar: twat.css('img.avatar').first.attribute('src').value,
	    }
	    security_tweets << tweet
	  end
	  ###### set sentiment ##############
	  security_tweets.each do |tweet|
	    body = tweet[:content] 
	  	tweet[:sentiment] = $analyzer.sentiment(body)
	    tweet[:score] = $analyzer.score(body)
	  end
	  @tweets = security_tweets

	end


	def browser_grab_images
		###### Redirect browser to get logo ######
		@browser.goto("https://www.bing.com/images/search?q=#{@company[:company_name]}%20icon")
	    sleep 0.5
	    parsed_page = Nokogiri::HTML(@browser.html)
	    logo = parsed_page.at_css("div.img_cont img").attribute('src').value
	    @logo = logo

	    ###### Redirect browser to get background ######
	    @browser.goto("https://www.bing.com/images/search?q=#{@company[:company_name]}%20company%20logo%20")
	    sleep 0.5
	    parsed_page = Nokogiri::HTML(@browser.html)
	    cover = parsed_page.at_css("div.img_cont img").attribute('src').value
	    @cover = cover
	end

 	def set_analyzer
	  $analyzer = Sentimental.new
	  $analyzer.load_defaults
	end

	def sentimental(tweets)
	  @tweets = tweets
	  negative = 0
	  positive = 0
	  score = 0
	  @tweets.each do |tweet|
	     score = score + tweet[:score]
	     if tweet[:score] < 0
	      negative += 1
	     else
	      positive += 1
	     end
	  end
	  @positive = (positive.to_f / 20 * 100).round
	  @negative = (negative.to_f / 20 * 100).round
	end



end
