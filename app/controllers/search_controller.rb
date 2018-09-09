require 'nokogiri'
require 'httparty'
require 'watir'
require 'sentimental'
require 'byebug'



class SearchController < ApplicationController
	 	
	
	def index
		# set search word #
		if params[:searchword]
			security_name = params[:searchword]
		elsif user_signed_in? && current_user.watchlists.any?
			security_name = "#{current_user.watchlists.last.name}"	
		else
			security_name = "google"
		end

		# automated browsing #
		automated_browser(security_name)

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


 	def automated_browser(security_name)
		security_name = security_name
 		# @browser = Watir::Browser.new(:chrome)
 		@browser = Watir::Browser.new :chrome, headless: true
	    @browser.goto("https://www.msn.com/en-my/money/")
	
	    @browser.text_field(id:"finance-autosuggest").set security_name
	    @browser.send_keys :enter
	    sleep 1
	    @parsed_page = Nokogiri::HTML(@browser.html)

 	end

 	def browser_company_info
 		@browser.div(class: "dynaloadable").ul.li(id: "profile").click
	    parsed_page = Nokogiri::HTML(@browser.html)
	    @browser.div(class:"rdmr-sels-btns").click
	    parsed_page = Nokogiri::HTML(@browser.html)

	    ######### company description #########
	    @company_description = parsed_page.css("div.company-description").text
	    @company_link = parsed_page.css("a.companyprofile-link").attribute('href').value
	    @company_sector = parsed_page.css("p.captionData").first.text
	end

	def browser_grab_images

		###### Redirect browser to get logo ######
		@browser.goto("https://www.bing.com/images/search?q=#{@company[:company_name]}%20icon")
	    sleep 1
	    parsed_page = Nokogiri::HTML(@browser.html)
	    logo = parsed_page.at_css("div.img_cont img").attribute('src').value
	    @logo = logo

	    ###### Redirect browser to get background ######
	    @browser.goto("https://www.bing.com/images/search?q=#{@company[:company_name]}%20company%20logo")
	    sleep 1
	    parsed_page = Nokogiri::HTML(@browser.html)
	    cover = parsed_page.at_css("div.img_cont img").attribute('src').value
	    @cover = cover

	end

 	def set_analyzer
	  $analyzer = Sentimental.new
	  $analyzer.load_defaults
	end

	def company_info(parsed_page)
		parsed_page = parsed_page
		company = {}
	    company = {
	      ticker: parsed_page.css("div.live-quote-subtitle").text.split.last,
	      company_name: parsed_page.css("div.live-quote-title").text.split.first,
	      twitter: parsed_page.css("div.live-quote-subtitle").text.split.last.insert(0,'$'),
	      twitter_mention: parsed_page.css("div.live-quote-subtitle").text.split.last.insert(0,'@'),
	      price: parsed_page.css("div.live-quote-bottom-tile span").first.text,
	      change_percent: parsed_page.css("div.live-quote-bottom-tile div div:nth-child(2)")[0].text,
	      change_price: parsed_page.css("div.live-quote-bottom-tile div div:nth-child(1)")[0].text 
	    }
	    @company = company
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
	  @avg_score = ((score / @tweets.count)*100).round
	end



end
