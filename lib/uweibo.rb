require "uweibo/version"

require 'yaml'
require 'weibo_2'

$app_root = File.expand_path("../..", __FILE__)
$config = YAML.load_file(File.join($app_root, 'config', 'weibo.yml')) rescue {}

WeiboOAuth2::Config.api_key = ENV['KEY']||$config[:app_key]
WeiboOAuth2::Config.api_secret = ENV['SECRET']||$config[:app_secret]
WeiboOAuth2::Config.redirect_uri = ENV['REDIR_URI']||$config[:callback_url]

module Uweibo
end

def weibo_client(id='1809866795')
  return @client if @client
  @client = WeiboOAuth2::Client.new
  token_file = File.join($app_root, 'tmp', "tokens_#{id}.yml")
  raise "First request a token file: #{token_file}" unless File.exists?(token_file)
  token_config = YAML.load_file(token_file)
  atoken = @client.get_token_from_hash(token_config)
  @client
end
