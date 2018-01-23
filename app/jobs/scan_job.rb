require 'csv'

class ScanJob
  include Sidekiq::Worker
  def perform(url, urlsafe_base64)
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    driver = Selenium::WebDriver.for :chrome, options: options
    client = Elasticsearch::Client.new log: true, host: 'elasticsearch'
    uuid = urlsafe_base64
    driver.get url

    page_text = driver.find_element(tag_name: 'body').text.downcase
    filtered_words = CSV.read(Rails.root.join('data', '100-common-words.csv'))
    filter_regex = filtered_words.map{|word| "\\b" + word[0] + "\\b|" }.join
    filter_regex = filter_regex[0..-2]
    stripped_text = page_text.gsub(Regexp.new(filter_regex), '')
    client.index index: 'page', id: uuid, type: 'page_body', body: { text: stripped_text, url: url }
  end
end