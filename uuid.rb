require 'sinatra'
require 'rest_client'
require 'securerandom'
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

#load Logs table defination
require './logs'

def create_guid(len=10)
  SecureRandom.hex(len)
end

def gen_rand(max=0.1)
    a = Random.new
    a.rand(max).round(3)
end


configure do
    enable :sessions
    set :root, File.dirname(__FILE__)
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
    @data = []
    #@data =  Logs.getlog(params[:uuid])
    @data =  Logs.getstack(params[:uuid])

    haml :timeline_chart
end


#init session[:guid] and session[:service_id]
before do
    #p request.cookies
    
    if session[:guid].nil?
        session[:guid] = ""
    end
    
    if session[:service_id].nil?
        session[:service_id] = ""
    end
    
    #pass the cookie to session for both guid and service_id
    session[:guid] = request.cookies["guid"] if !request.cookies["guid"].nil?
    session[:service_id] = request.cookies["service_id"] if !request.cookies["service_id"].nil?
    
end


#page filter
before '/page/*' do
    p "---before a page call---"
    #p session
    
    session[:guid]=create_guid(10)
    
    @page_entry_time = Time.now.to_f
    @request_path = request.path
    @type = "0"
    @service_id = session[:service_id]
    @guid = session[:guid]
    
    #Send stream data to kafka or else
    #p "#{@request_path}|#{@guid}|#{@service_id}|#{@type}|#{@page_entry_time}|"
    Logs.setlog(@request_path,@type,@guid,@service_id,@page_entry_time)
    
end

after '/page/*' do
    p "---after a page call---"
    #p session
    
    @page_exit_time = Time.now.to_f
    @request_path = request.path
    @type = "1"
    @service_id = session[:service_id]
    @guid = session[:guid]
    
    #Send stream data to kafka or else
    #p "#{@request_path}|#{@guid}|#{@service_id}|#{@type}|#{@page_exit_time}|"
    Logs.setlog(@request_path,@type,@guid,@service_id,@page_exit_time)
    
    #clear GUID after a page request
    session[:guid].clear
    
end


#service filter
before '/rest/*' do 
    p "---before a service call---"
    #p session
    
    if session[:service_id].empty? #the very first serice call
        if session[:guid].empty?
            session[:service_id] = create_guid(8) + 'a'
        else 
            session[:service_id] = session[:guid] + 'a'
        end
    else 
        session[:service_id] = session[:service_id] + 'a'
    end
    
    @service_entry_time = Time.now.to_f
    @request_path = request.path
    @type = "00"
    @service_id = session[:service_id]
    @guid = session[:guid]
    
    #Send stream data to kafka or else
    #p "#{@request_path}|#{@guid}|#{@service_id}|#{@type}|#{@service_entry_time}|"
    Logs.setlog(@request_path,@type,@guid,@service_id,@service_entry_time)

end

after '/rest/*' do
    p "---after a service call---"
    
    @service_exit_time = Time.now.to_f
    @request_path = request.path
    @type = "11"
    @service_id = session[:service_id]
    @guid = session[:guid]
    
    #Send stream data to kafka or else
    #p "#{@request_path}|#{@guid}|#{@service_id}|#{@type}|#{@service_exit_time}|"
    Logs.setlog(@request_path,@type,@guid,@service_id,@service_exit_time)
    
    #chop last char if length of service_id > guid
    session[:service_id].chop!
    if (session[:service_id].length == session[:guid].length) || (session[:service_id].length == 16)
        session[:service_id].clear
    end
end
