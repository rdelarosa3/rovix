
<img width="1663" alt="Screen Shot 2021-01-27 at 2 28 45 AM" src="https://user-images.githubusercontent.com/40813295/105964188-78c43080-6047-11eb-809e-d96bd89a91d8.png">

<b></b>
<b></b>
<p align="center"> 
ROvIX is a full-stack Ruby application, built on the Rails framework. This Web App allows users the ability to track publicly
traded companies market data, news and social sentiment. 
</p>

## Table of Contents
1. [Demo](https://github.com/rdelarosa3/rovix#demo)
2. [Technologies Applied](https://github.com/rdelarosa3/rovix#technologies)
3. [Setup Instruction](https://github.com/rdelarosa3/rovix#setup-instruction)
4. [Contribution](https://github.com/rdelarosa3/rovix#contribution)
### Demo
[rovix.herokuapp.com](https://rovix.herokuapp.com/)
                         
### Technologies
- Oauth2 [link](https://oauth.net/2/)
- AWS S3 [link](https://aws.amazon.com/s3/)
- Watir Selenium Web Driver [link](http://watir.com/)
- Nokogiri (parser) [link](https://nokogiri.org/)
- HTTPParty (parser)
- Bootstrap [link](https://getbootstrap.com/)
- jQuery [link](https://jquery.com/)
- Rails 5.2 
- Ruby
- Active Record
- PostgreSQL
- Heroku


### Setup Instruction

<p>Prerequisites

The setups steps expect following tools installed on the system.

- Ruby 2.6.6
- Rails 5.2
- AWS S3 bucket and credentials

<p>1. Check out the repository </p>

```bash
git clone git@github.com:rdelarosa3/rovix.git
```

<p>2. Create database.yml file </p>

Copy the sample database.yml file and edit the database configuration as required.

```bash
cp config/database.yml.sample config/database.yml
```

<p>3. Create and setup the database </p>

Run the following commands to create and setup the database.

```ruby
bundle exec rake db:create
bundle exec rake db:setup
```

<p>4. Start the Rails server </p>

You can start the rails server using the command given below.

```ruby
bundle exec rails s
```

And now you can visit the site with the URL http://localhost:3000

### Contribution
**This list is in alphabetical order**

<details>
  <summary>Robert De laRosa <a href="https://github.com/rdelarosa3" target="_blank">GitHub</a></summary>

  1. Implementation of Device for Security 
  2. Integration of AWS S3 for remote file storage
  3. Implementation and setup for Oauth2 with Facebook
  4. UX/UI design using JS, CSS, JQuery, and Bootstrap libraries
  5. Web Driver Automation and Parsing of data to ruby objects
</details>
