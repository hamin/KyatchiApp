#
#  generic_server.rb
#  KyatchiApp
#
#  Created by Haris Amin on 8/7/11.
#  Copyright 2011 __MyCompanyName__. All rights reserved.
#

require 'socket'
class GenericServer
  attr_accessor :eml, :socket, :status, :request_group, :request_queue, :client_data
  
  def initialize(host, port, opts={})
    self.client_data = Hash.new
    self.eml = ""
    @host = host
    @port = port
    @socket = TCPServer.new(host, port)
    @socket.listen(50)
    @status = :closed # Start closed and give the server time to start
    
    @request_queue = Dispatch::Queue.concurrent
    #@request_group = Dispatch::Group.new
    # log "initialization complete."
  end
  
  def open(restart=false)
    # log "opening..."
    NSLog "opening..."
    
    if restart == true
      @socket = TCPServer.new(@host, @port)
      @socket.listen(50)
      #@status = :closed  
    end  
    @status = :open
    while (@status == :open)

      # log "Control Tower: waiting for connection..."
      client, connection, remote_addrinfo_str = @socket.accept
      
      # -------------- PROCESS REQUEST ASYNCHRONOUSLY ----------------

      @request_queue.async do
        begin
          client_addr = client.addr
          #NSLog "#{self.class.to_s} accepted connection #{client.object_id} from #{client_addr.inspect}"
          greet client

          # Keep processing commands until somebody closed the connection
          begin
            input = client.gets
            @eml += input

            # The first word of a line should contain the command
            command = input.to_s.gsub(/ .*/,"").upcase.gsub(/[\r\n]/,"")

            NSLog "#{client.object_id}:#{@port} < #{input}"

            process(client, command, input)
          end until client.closed?
          #NSLog "#{self.class.to_s} closed connection #{client.object_id} with #{client_addr.inspect}"
          rescue => detail
          NSLog "#{client.object_id}:#{@port} ! #{$!}"
          client.close
        end
      end # @request_queue 
    end # while :open
    
  end
  
  def close
    puts "Received shutdown signal.  Waiting for current requests to complete..."
    @status = :close
    
    # 60 seconds to empty the request queue
    Dispatch::Source.timer(60, 0, 1, Dispatch::Queue.concurrent) do
      puts "Timed out waiting for connections to close. Stopping server with pid=#{Process.pid}."
      #exit
    end
    
    #@request_group.wait
    @socket.close
    puts "All requests completed. Stopping server with pid=#{Process.pid}."      
    #exit
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
