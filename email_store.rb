#
#  email_store.rb
#  KyatchiApp
#
#  Created by Haris Amin on 8/12/11.
#  Copyright 2011 __MyCompanyName__. All rights reserved.
#
require 'singleton'
require 'mail'
class EmailStore
  include Singleton
  
  attr_accessor :moc
  
  def initialize
  end
  
  def add_message(eml, moc)
    @moc = moc
    mail = Mail.new eml
    new_email = NSEntityDescription.insertNewObjectForEntityForName("Email", inManagedObjectContext:@moc)
    
    new_email.from = mail.from.first
    new_email.to = mail.to.first
    new_email.subject = mail.subject
    new_email.received = NSDate.new
    
    if mail.multipart?
      new_email.html = mail.html_part.decoded
      new_email.plain = mail.text_part.decoded
      new_email.raw = mail.to_s
    else
      new_email.html = '' # cannot store nil ?
      new_email.plain = mail.body.decoded
      new_email.raw = mail.to_s
    end
    
    @moc.save(nil)

  end  
  
end

