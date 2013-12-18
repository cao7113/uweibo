# encoding: utf-8
require 'rubygems'
require 'bundler'
Bundler.require

$:.unshift File.expand_path(__FILE__)
require 'uweibo'

enable :sessions

get '/' do
  client = WeiboOAuth2::Client.new
  if session[:access_token] && !client.authorized?
    token = client.get_token_from_hash({:access_token => session[:access_token], :expires_at => session[:expires_at]}) 
    p "*" * 80 + "validated"
    p token.inspect
    p token.validated?
    
    unless token.validated?
      reset_session
      redirect '/connect'
      return
    end
  end

  if session[:uid]
    @user = client.users.show_by_uid(session[:uid]) 
    @statuses = client.statuses
  end
  haml :index
end

get '/connect' do
  client = WeiboOAuth2::Client.new
  #应用认证之后 redirect_uri的path就可以和注册的不一样啦？神奇
  redirect client.authorize_url #(redirect_uri: "http://xxx.com/callback1")
end

get '/auth/weibo/callback' do
  client = WeiboOAuth2::Client.new
  access_token = client.auth_code.get_token(params[:code].to_s)
  session[:uid] = access_token.params["uid"]
  session[:access_token] = access_token.token
  session[:expires_at] = access_token.expires_at
  p "*" * 80 + "callback"
  p access_token.inspect
  #TODO 写个独立自动程序完成这个
  token_file = File.join($tmp_root, "token_#{session[:uid]}.yml")
  unless File.exists?(token_file)
    File.write(token_file, {access_token: session[:access_token], expires_at: session[:expires_at].to_i}.to_yaml)
  end
  @user = client.users.show_by_uid(session[:uid].to_i)
  redirect '/'
end

get '/auth/weibo/cancel_callback' do
  puts "Cancel authorizations..........."
  redirect '/'
end

get '/logout' do
  reset_session
  redirect '/'
end 

get '/screen.css' do
  content_type 'text/css'
  sass :screen
end

post '/update' do
  client = WeiboOAuth2::Client.new
  client.get_token_from_hash({:access_token => session[:access_token], :expires_at => session[:expires_at]}) 
  statuses = client.statuses

  unless params[:file] && (pic = params[:file].delete(:tempfile))
    statuses.update(params[:status])
  else
    status = params[:status] || '图片'
    statuses.upload(status, pic, params[:file])
  end

  redirect '/'
end

helpers do 
  def reset_session
    session[:uid] = nil
    session[:access_token] = nil
    session[:expires_at] = nil
  end
end
