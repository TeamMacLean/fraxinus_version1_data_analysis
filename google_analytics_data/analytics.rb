# Modified from https://github.com/google/google-api-ruby-client-samples/blob/1480725b07e7048bc5dc7048606a016c5a8378a7/service_account/analytics.rb
# Inspired by https://gist.github.com/3166610
require 'rubygems'
require 'google/api_client'
require 'date'
require 'yaml'

API_VERSION = 'v3'
CACHED_API_FILE = "analytics-#{API_VERSION}.cache"

opts = YAML.load_file("ga_config.yml")

# Update these to match your own apps credentials
service_account_email = opts['service_account_email']  # Email of service account
key_file = opts['key_file']                            # File containing your private key
key_secret = opts['key_secret']                        # Password to unlock private key
@profileID = opts['profileID'].to_s                    # Analytics profile ID.

#@startDate = DateTime.now.prev_month.strftime("%Y-%m-%d")
@startDate = Date.parse('2013-08-12').to_s
@endDate = Date.parse('2014-08-04').to_s
#@endDate = DateTime.now.strftime("%Y-%m-%d")
puts @startDate
puts @endDate


@client = Google::APIClient.new(
  :application_name => opts['application_name'],
  :application_version => opts['application_version'])

# Load our credentials for the service account
key = Google::APIClient::KeyUtils.load_from_pkcs12(key_file, key_secret)
  
@client.authorization = Signet::OAuth2::Client.new(
  :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
  :audience => 'https://accounts.google.com/o/oauth2/token',
  :scope => 'https://www.googleapis.com/auth/analytics.readonly',
  :issuer => service_account_email,
  :signing_key => key)

# Request a token for our service account
@client.authorization.fetch_access_token!

@analytics = nil
# Load cached discovered API, if it exists. This prevents retrieving the
# discovery document on every run, saving a round-trip to the discovery service.
if File.exists? CACHED_API_FILE
  File.open(CACHED_API_FILE) do |file|
    @analytics = Marshal.load(file)
  end
else
  @analytics = client.discovered_api('analytics', API_VERSION)
  File.open(CACHED_API_FILE, 'w') do |file|
    Marshal.dump(@analytics, file)
  end
end

# => Query Parameters Summary https://developers.google.com/analytics/devguides/reporting/core/v3/reference#q_summary
def query_ga (dimension, metric, sort, date) # dimension is a single string, could be multiple then we could use array to parse
  query_data = @client.execute(:api_method => @analytics.data.ga.get, :parameters => { 
    'ids' => "ga:" + @profileID, 
    'start-date' => date,
    'end-date' => date,
    'dimensions' => dimension,
    'metrics' => metric,
    'sort' => sort
  })
  return query_data
end

# => Dimensions and Metrics Reference: https://developers.google.com/analytics/devguides/reporting/core/dimsmets
# => A single dimension data request to be retrieved from the API is limited to a maximum of 7 dimensions
# => A single metrics data request to be retrieved from the API is limited to a maximum of 10 metrics

## Page visits "ga:visits: Counts the total number of sessions"
attributes = YAML.load_file("ga_attributes.yml")
first = Date.parse('2013-08-08')
last = Date.parse('2014-08-04')

attributes.each_key { |key|
  outfile = File.new("#{key}.txt", "w")
  colhead = ''
  first.upto(last) do |date|
    puts date
    gadata = query_ga(attributes[key]['dimension'], attributes[key]['metric'], attributes[key]['sort'], date.to_s)
    colhead = gadata.data.column_headers.map { |c| c.name.gsub("ga:","") }.join("\t")
    gadata.data.rows.each do |r|
      outfile.print "#{date}\t"
      outfile.puts r.join("\t")
    end
  end
  outfile.puts "#{colhead}"
}
