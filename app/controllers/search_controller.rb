require 'nokogiri'
require 'httparty'
require 'watir'
class SearchController < ApplicationController

	def index
	    browser = Watir::Browser.new(:chrome)
	    browser.goto("https://www.msn.com/en-my/money/stockdetails/fi-126.1.AAPL.NAS?symbol=AAPL&form=PRFIMQ")
	    security_name = "chipotle"
	    browser.text_field(id:"finance-autosuggest").set security_name
	    browser.send_keys :enter
	    sleep 1
	    parsed_page = Nokogiri::HTML(browser.html)

	    ####### COMPANY ########
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

	    #### ARTICLES ######
	    articles = []
	    article = {}
	    news_links = parsed_page.css(".bingNewsContainer a")

	    news_links.each do |x|
	      article = {
	        body: x.css("h3").text,
	        link: x.attributes["href"].value,
	        source: x.css("span.sourcename").text,
	        timeframe: x.css("span.dt").text 
	        }

	      articles << article
	    end

	    ######### company description
	    browser.div(class: "dynaloadable").ul.li(id: "profile").click
	    parsed_page = Nokogiri::HTML(browser.html)
	    browser.div(class:"rdmr-sels-btns").click
	    parsed_page = Nokogiri::HTML(browser.html)
	    @company_description = parsed_page.css("div.company-description").text
	    @company_link = parsed_page.css("a.companyprofile-link").attribute('href').value
	    @company_sector = parsed_page.css("p.captionData").first.text

	    ########## twitter ################
	    browser.goto("https://twitter.com/search?f=tweets&q=#{company[:twitter]}")
	    parsed_page = Nokogiri::HTML(browser.html)
	    tweets = parsed_page.css('div.tweet')
	    security_tweets = []
	    tweets.each do |twat|
	      tweet = {
	      fullname: twat.css('strong.fullname').text,
	      username: twat.css('span.username').text,
	      when: twat.css('span.u-hiddenVisually').first.text,
	      content: twat.css('p.TweetTextSize').text,
	      avatar: twat.css('img.avatar').first.attribute('src').value
	      }
	      security_tweets << tweet
	    end
	    ###### LOGO's ###########
	    browser.goto("https://www.bing.com/images/search?q=#{company[:company_name]}%20logo")
	    sleep 1
	    parsed_page = Nokogiri::HTML(browser.html)
	    logo = parsed_page.at_css("div.img_cont img").attribute('src').value
	    ###### Background ######
	    browser.goto("https://www.bing.com/images/search?&q=#{company[:company_name]}%20logo&qft=+filterui:imagesize-custom_1000_320&FORM=IRFLTR")
	    sleep 1
	    parsed_page = Nokogiri::HTML(browser.html)
	    cover = parsed_page.at_css("div.img_cont img").attribute('src').value
	    browser.close
	    @cover = cover
	    @logo = logo
	    @company = company
	    @articles = articles
	    @tweets = security_tweets

 	end



end
