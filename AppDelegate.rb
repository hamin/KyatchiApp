#
# AppDelegate.rb
# KyatchiApp
#
# Created by Haris Amin on 6/13/11.
# Copyright __MyCompanyName__ 2011. All rights reserved.
#÷
require 'smtp_server'

class AppDelegate
  attr_writer :window
  attr_accessor :emails
  attr_accessor :rawTextView, :plainTextView, :htmlWebView, :htmlSourceWebView
  attr_accessor :fromLabel, :subjectLabel, :dateLabel, :toLabel
  attr_accessor :sliderControl, :sliderToolbar, :sliderView
	
	def awakeFromNib
		#seedData
    @sliderToolbar.setView(sliderView)
    @sliderControl.setStateNoAction(NSOnState)
    Thread.new{
      @smtp_server = SMTPServer.new('localhost', 1025, :moc => @managedObjectContext)
      @smtp_server.start 
    }
	end
  
  def sliderChanged(sender)
    NSLog "SLIDER WAS CHANGED!!!!"
  end  
	
  def tableViewSelectionDidChange(notification)
    email_object = @emails.selectedObjects.first
    
    @fromLabel.stringValue = email_object.from
    @subjectLabel.stringValue = email_object.subject
    @dateLabel.stringValue  = email_object.received
    @toLabel.stringValue = email_object.to
    @rawTextView.setString( email_object.raw )
    @plainTextView.setString( email_object.plain )
    
    unless email_object.blank?
      load_webviews = Proc.new do
        @htmlWebView.mainFrame.loadHTMLString(email_object.html,  baseURL: nil)
        @htmlSourceWebView.mainFrame.loadHTMLString(email_object.html_source,  baseURL: nil)
      end
      load_webviews.performSelectorOnMainThread( 'call', withObject: nil, waitUntilDone: true)
    end  
  end 
  
  
  def seedData
    email = NSEntityDescription.insertNewObjectForEntityForName("Email", inManagedObjectContext:@managedObjectContext)
		
		email.from = "hristo@dailyburn.com"
		email.to = "foo@example.com"
		email.subject = "Something cool"
		email.received = NSDate.date
		email.raw = "SDFASFHHJJL BABY HRISTO"
		email.html = "<h1> OK</h1>"
		email.plain = "OK THERE BUDDY"
    
    @managedObjectContext.save(nil)
  end

  # Returns the support folder for the application, used to store the Core Data
  # store file.  This code uses a folder named "KyatchiApp" for
  # the content, either in the NSApplicationSupportDirectory location or (if the
  # former cannot be found), the system's temporary directory.
  def applicationSupportFolder
    paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, true)
    basePath = paths[0] || NSTemporaryDirectory()
    basePath.stringByAppendingPathComponent("KyatchiApp")
  end

  # Creates and returns the managed object model for the application 
  # by merging all of the models found in the application bundle.
  def managedObjectModel
    @managedObjectModel ||= NSManagedObjectModel.mergedModelFromBundles(nil)
  end


  # Returns the persistent store coordinator for the application.  This 
  # implementation will create and return a coordinator, having added the 
  # store for the application to it.  (The folder for the store is created, 
  # if necessary.)
  def persistentStoreCoordinator
    unless @persistentStoreCoordinator
      error = Pointer.new_with_type('@')
    
      fileManager = NSFileManager.defaultManager
      applicationSupportFolder = self.applicationSupportFolder
    
      unless fileManager.fileExistsAtPath(applicationSupportFolder, isDirectory:nil)
        fileManager.createDirectoryAtPath(applicationSupportFolder, attributes:nil)
      end
    
      url = NSURL.fileURLWithPath(applicationSupportFolder.stringByAppendingPathComponent("KyatchiApp.xml"))
      @persistentStoreCoordinator = NSPersistentStoreCoordinator.alloc.initWithManagedObjectModel(self.managedObjectModel)
      unless @persistentStoreCoordinator.addPersistentStoreWithType(NSXMLStoreType, configuration:nil, URL:url, options:nil, error:error)
        NSApplication.sharedApplication.presentError(error[0])
      end
    end

    @persistentStoreCoordinator
  end

  # Returns the managed object context for the application (which is already
  # bound to the persistent store coordinator for the application.) 
  def managedObjectContext
    unless @managedObjectContext
      coordinator = self.persistentStoreCoordinator
      if coordinator
        @managedObjectContext = NSManagedObjectContext.new
        @managedObjectContext.setPersistentStoreCoordinator(coordinator)
      end
    end
    
    @managedObjectContext
  end

  # Returns the NSUndoManager for the application.  In this case, the manager
  # returned is that of the managed object context for the application.
  def windowWillReturnUndoManager(window)
    self.managedObjectContext.undoManager
  end

  # Performs the save action for the application, which is to send the save:
  # message to the application's managed object context.  Any encountered errors
  # are presented to the user.
  def saveAction(sender)
    error = Pointer.new_with_type('@')
    unless self.managedObjectContext.save(error)
      NSApplication.sharedApplication.presentError(error[0])
    end
  end

  # Implementation of the applicationShouldTerminate: method, used here to
  # handle the saving of changes in the application managed object context
  # before the application terminates.
  def applicationShouldTerminate(sender)
    error = Pointer.new_with_type('@')
    reply = NSTerminateNow
    
    if managedObjectContext
      if managedObjectContext.commitEditing
        if managedObjectContext.hasChanges && (not managedObjectContext.save(error))
          # This error handling simply presents error information in a panel with an 
          # "Ok" button, which does not include any attempt at error recovery (meaning, 
          # attempting to fix the error.)  As a result, this implementation will 
          # present the information to the user and then follow up with a panel asking 
          # if the user wishes to "Quit Anyway", without saving the changes.

          # Typically, this process should be altered to include application-specific 
          # recovery steps.  

          errorResult = NSApplication.sharedApplication.presentError(error[0])
          
          if errorResult
            reply = NSTerminateCancel
          else
            alertReturn = NSRunAlertPanel(nil, "Could not save changes while quitting. Quit anyway?" , "Quit anyway", "Cancel", nil)
            if alertReturn == NSAlertAlternateReturn
              reply = NSTerminateCancel
            end
          end
        end
      else
        reply = NSTerminateCancel
      end
    end
    
    reply
  end

end
