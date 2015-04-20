
require 'securerandom'

def create_guid(len=10)
  SecureRandom.hex(len)
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