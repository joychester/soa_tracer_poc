require 'sinatra'
require 'rest_client'
require 'yaml'
require 'sequel'
require 'pg'
#require 'haml' #comment this as this is not a thread safe way...
require 'tilt/haml'


#load global config file
CONFIG = YAML.load_file('config.yml')

#Connect to Postgresql service
DB = Sequel.connect(CONFIG['dbconnect'])
Sequel.database_timezone = :utc


configure do
    enable :sessions
    set :root, File.dirname(__FILE__)
end

require './filter'
#load Logs table defination
require './logs'

def gen_rand(max=0.1)
    a = Random.new
    a.rand(max).round(3)
end

get '/' do 
    redirect '/report/gettop'
end

get '/rest/serviceA' do
    sleep gen_rand
    p 'hello service A!'
    #call a serviceB
    RestClient.get 'http://localhost:4567/rest/serviceB' ,{:cookies => {:service_id => session[:service_id], :guid => session[:guid]}}

end

get '/rest/serviceB' do
    sleep gen_rand

    p 'hello, this is service B!'
end

get '/rest/serviceC' do
    sleep gen_rand

    p 'hello, this is service C!'
end

get '/page/pageA' do 
    sleep gen_rand
    #call a serviceA
    RestClient.get 'http://localhost:4567/rest/serviceA' ,{:cookies => {:guid => session[:guid]}}
    
    sleep gen_rand

    p "hello, this is page A! #{session[:guid]}"
end

get '/page/pageB' do 
    sleep gen_rand

    p "hello, this is page B! #{session[:guid]}"
end

get '/page/pageC' do
    sleep gen_rand
    #call a serviceA
    RestClient.get 'http://localhost:4567/rest/serviceA' ,{:cookies => {:guid => session[:guid]}}

    sleep gen_rand
    #call a serviceA
    RestClient.get 'http://localhost:4567/rest/serviceC' ,{:cookies => {:guid => session[:guid]}}

    sleep gen_rand
    p "hello, this is page C! #{session[:guid]}"
end


get '/report/gettop' do
    @top_uuid = Logs.gettop

    haml :uuid_link
end


get '/report/:uuid' do 
    @uuid = params[:uuid]
    @data = []
    p @data =  Logs.getstack(@uuid)

    haml :timeline_chart
end

get '/d3/:uuid' do 
    @json_tree = Logs.gettree(params[:uuid])
end

get '/d3/treeview/:uuid' do
    @uuid = params[:uuid]
    haml :d3_treeview
end
