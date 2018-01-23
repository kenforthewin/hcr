require 'selenium-webdriver'
# require 'csv'
# require 'resolv'
require 'elasticsearch'
require 'pp'
require 'securerandom'
# configure the driver to run in headless mode
options = Selenium::WebDriver::Chrome::Options.new
options.add_argument('--headless')
driver = Selenium::WebDriver.for :chrome, options: options
client = Elasticsearch::Client.new log: true
# TODO for now, we'll have single-page analysis. Soon we may scan a whole website, or a range of ips.
# sitemap = SitemapParser.new('http://ben.balter.com/sitemap.xml', {recurse: true})

client.indices.create index: 'page',
            body: {
              mappings: {
                page_body: {
                  properties: {
                    text: {
                      type: 'text',
                      term_vector: 'with_positions_offsets_payloads',
                      store: true
                    },
                    url: {
                      type: 'text',
                      store: true
                    }
                }
              }
            }
          }


uuid = SecureRandom.urlsafe_base64
driver.get ENV['USER_DOMAIN']

page_text = driver.find_element(tag_name: 'body').text
client.index index: 'page', id: uuid, type: 'page_body', body: { text: page_text }

client.termvector index: 'page', id: uuid, fields: ['text'], type: 'page_body'