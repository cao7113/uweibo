require "uweibo/version"

require 'yaml'
require 'fileutils'
require 'weibo_2'

$app_root = File.expand_path("../..", __FILE__)
#rackup -e 启动时是设置的 RACK_ENV??
$env = ENV['RACK_ENV']||'development'
$config = YAML.load_file(File.join($app_root, 'config', 'weibo.yml'))[$env.to_sym] #rescue {}
$tmp_root = File.join($app_root, 'tmp')
FileUtils.mkdir_p($tmp_root) unless File.directory?($tmp_root)

WeiboOAuth2::Config.api_key = ENV['KEY']||$config[:app_key]
WeiboOAuth2::Config.api_secret = ENV['SECRET']||$config[:app_secret]
WeiboOAuth2::Config.redirect_uri = ENV['REDIR_URI']||$config[:callback_url]

module Uweibo
  def self.my_client(uid='1809866795')
    return @client if @client
    @client = WeiboOAuth2::Client.new
    @client.get_token_from_hash(token_hash(uid))
    @client
  end

  def self.token_hash(uid='1809866795')
    token_file = File.join($tmp_root, "token_#{uid}.yml")
    raise "First request a token file: #{token_file} at http://weiboapp.lh:9888" unless File.exists?(token_file)
    YAML.load_file(token_file)
  end
end
