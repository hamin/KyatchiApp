#
#  smtp_server.rb
#  KyatchiApp
#
#  Created by Haris Amin on 8/7/11.
#  Copyright 2011 __MyCompanyName__. All rights reserved.
#


require 'generic_server.rb'
require 'email_store'

# Basic SMTP server

class SMTPServer < GenericServer
  attr_accessor :moc
  
  # Create new server listening on port
  def initialize(host, port, opts={})
    @moc = opts[:moc]
    super(host, port, opts)
  end
  
  def start
    trap 'INT' do
      self.close
      exit
    end
    
    # Ok, let the server do it's thing
    self.open
  end
  
  def stop
    self.close
  end
  
  # Send a greeting to client
  def greet(client)
    respond(client, 220)
  end
  
  # Process command
  def process(client, command, full_data)
    case command
      when 'DATA' then data(client)
      when 'HELO', 'EHLO' then respond(client, 250)
      when 'MAIL' then mail_from(client, full_data)
      when 'QUIT' then quit(client)
      when 'RCPT' then rcpt_to(client, full_data)
      when 'RSET' then rset(client)
      else begin
        if get_client_data(client, :sending_data)
          append_data(client, full_data)
          else
          respond(client, 500)
        end
      end
    end
  end
  
  # Closes connection
  def quit(client)
    respond(client, 221)
    client.close
  end
  
  # Stores sender address
  def mail_from(client, full_data)
    if /^MAIL FROM:/ =~ full_data.upcase
      set_client_data(client, :from, full_data.gsub(/^MAIL FROM:\s*/i,"").gsub(/[\r\n]/,""))
      respond(client, 250)
      else
      respond(client, 500)
    end
  end
  
  # Stores recepient address
  def rcpt_to(client, full_data)
    if /^RCPT TO:/ =~ full_data.upcase
      set_client_data(client, :to, full_data.gsub(/^RCPT TO:\s*/i,"").gsub(/[\r\n]/,""))
      respond(client, 250)
      else
      respond(client, 500)
    end
  end
  
  # Marks client sending data
  def data(client)
    set_client_data(client, :sending_data, true)
    respond(client, 354)
  end
  
  # Resets local client store
  def rset(client)
    self.client_data[client.object_id] = Hash.new
    self.eml = ""
  end
  
  # Adds full_data to incoming mail message
  #
  # We'll store the mail when full_data == "."
  def append_data(client, full_data)
    if full_data.gsub(/[\r\n]/,"") == "."
      
      EmailStore.instance.add_message( @eml, @moc )
      respond(client, 250)
      
      NSLog "Received mail from #{get_client_data(client, :from).to_s} with recipient #{get_client_data(client, :to).to_s}"
      else
      set_client_data(client, :data, get_client_data(client, :data).to_s + full_data)
    end
  end
  
  protected
  
  # Store key value combination for this client
  def set_client_data(client, key, value)
    self.client_data[client.object_id] = Hash.new unless self.client_data.include?(client.object_id)
    self.client_data[client.object_id][key] = value
  end
  
  # Retreive key from local client store
  def get_client_data(client, key)
    self.client_data[client.object_id][key] if self.client_data.include?(client.object_id)
  end
  
  # Respond to client using a standard SMTP response code
  def respond(client, code)
    super(client, "#{code} #{SMTPServer::RESPONSES[code].to_s}\r\n")
  end
  
  # Standard SMTP response codes
  RESPONSES = {
  500 => "Syntax error, command unrecognized",
  501 => "Syntax error in parameters or arguments",
  502 => "Command not implemented",
  503 => "Bad sequence of commands",
  504 => "Command parameter not implemented",
  211 => "System status, or system help respond",
  214 => "Help message",
  220 => "Kyatchi Mail Service ready",
  221 => "Kyatchi Mail Service closing transmission channel",
  421 => "Kyatchi Mail Service not available,",
  250 => "Requested mail action okay, completed",
  251 => "User not local; will forward to <forward-path>",
  450 => "Requested mail action not taken: mailbox unavailable",
  550 => "Requested action not taken: mailbox unavailable",
  451 => "Requested action aborted: error in processing",
  551 => "User not local; please try <forward-path>",
  452 => "Requested action not taken: insufficient system storage",
  552 => "Requested mail action aborted: exceeded storage allocation",
  553 => "Requested action not taken: mailbox name not allowed",
  354 => "Start mail input; end with <CRLF>.<CRLF>",
  554 => "Transaction failed"
  }.freeze
end