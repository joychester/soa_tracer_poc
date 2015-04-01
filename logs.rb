class Logs < Sequel::Model(:logs)
    
            def Logs.setlog(path,type,guid,service_id,ts)
                Logs.insert(:url_name => path, :type => type, :pageid => guid, :serviceid => service_id, :ts => ts)
            end

            def Logs.gettop
            	#select random pageid from logs 
            	p Logs.with_sql("select pageid from logs order by random()").get(:pageid)
            end

            def Logs.getstack(uuid)
            	array_a = []
            	sid = ''
            	base = 0
            	# SELECT * FROM logs WHERE (pageid = 'a730e0683057c8abbe79')
            	item_len = Logs.where(:pageid => uuid).count
            	row_id = Logs.with_sql("select id from logs where pageid = '#{uuid}' and (type = '0' or type = '00')")
            	start_id = row_id.get(:id)
            	call_depth = row_id.count

            	if item_len % 2 == 0
            		call_depth.times do
            			temp_a = []
            			
            			name = Logs.with_sql("select url_name from logs where pageid = '#{uuid}' and id >= #{start_id} and (type = '0' or type = '00')").get(:url_name)
            			start_ts = Logs.with_sql("select ts from logs where pageid = '#{uuid}' and url_name = '#{name}' and (type = '0' or type = '00')").get(:ts)
            			end_ts = Logs.with_sql("select ts from logs where pageid = '#{uuid}' and url_name = '#{name}' and (type = '1' or type = '11')").get(:ts)

            			#convert to ms
            			start_ts = (start_ts * 1000).to_i
            			end_ts = (end_ts * 1000).to_i

            			if base == 0
            				base = start_ts
            			end

            			temp_a = [name,(start_ts-base),(end_ts-base)]
            			array_a << temp_a

            			current_entry_id = Logs.with_sql("select id from logs where pageid = '#{uuid}' and url_name = '#{name}' and (type = '0' or type = '00')").get(:id)
            			start_id = current_entry_id + 1
            		end
            	else
            		p "not a complete call stack, missing something..."
            		return array_a #nil
            	end

            	return array_a
            end

end