#
#  generic_server.rb
#  KyatchiApp
#
#  Created by Haris Amin on 8/7/11.
#  Copyright 2011 __MyCompanyName__. All rights reserved.
#

require 'socket'
class GenericServer
  
  def initialize(options)
    @port = options[:port]
    server = TCPServer.open(@port)
    #$log.info "#{self.class.to_s} listening on port #{@port}"
    
    # Accept connections until infinity and beyond
    loop do
      Thread.start(server.accept) do |client|
        begin
          client_addr = client.addr
          NSLog "#{self.class.to_s} accepted connection #{client.object_id} from #{client_addr.inspect}"
          greet client
          
          # Keep processing commands until somebody closed the connection
          begin
            input = client.gets
            
            # The first word of a line should contain the command
            command = input.to_s.gsub(/ .*/,"").upcase.gsub(/[\r\n]/,"")
            
            NSLog "#{client.object_id}:#{@port} < #{input}"
            
            process(client, command, input)
          end until client.closed?
          NSLog "#{self.class.to_s} closed connection #{client.object_id} with #{client_addr.inspect}"
          rescue => detail
          NSLog "#{client.object_id}:#{@port} ! #{$!}"
          client.close
        end
      end
    end
  end
  
  # Respond to client by sending back text
  def respond(client, text)
    NSLog "#{client.object_id}:#{@port} > #{text}"
    client.write text
    rescue
    NSLog "#{client.object_id}:#{@port} ! #{$!}"
    client.close
  end
  
end
