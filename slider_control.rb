# #
# #  slider_control.rb
# #  KyatchiApp
# #
# #  Created by Haris Amin on 8/26/11.
# #  Copyright 2011 __MyCompanyName__. All rights reserved.
# #
# framework 'Cococa'
# 
# class SliderControl < NSImageView
#   kTMSliderControlState_Inactive = 0
#   kTMSliderControlState_Active = 1
#   
#   def initWithFrame(NSRect:frame)
#     self = super(frame)
#     
#     if self
#       sliderWell = NSImage.imageNamed('SliderWell')
#       overlayMask = NSImage.imageNamed('OverlayMask')
#       sliderHandle = NSImage.imageNamed('SliderHandle')
#       sliderHandleDown = NSImage.imageNamed('SliderHandleDown')
#       self.layoutHandle
#       sliderHandleView = SliderControlHandle.alloc.initWithFrame(handleControlRectOff)
#       sliderHandleDown.setWantsLayer(true)
#       self.addSubview(sliderHandleView)
#       state = false
#     end
#     
#     return self
#   end
#   
#   def awakeFromNib
#     self.setWantsLayer(true)
#   end
#   
#   def drawRect(NSRect:rect)
#     drawBacking
#     drawHandle
#     drawOverlay
#   end
#   
#   def acceptsFirstResponder
#     true
#   end
#   
#   def mouseDown(NSEvent: theEvent)
#     mousePoint = self.convertPoint(theEvent.locationInWindow)
#     hasDragged = false
#     
#     if NSPointInRect(mousePoint, handleControlRect)
#       controlState = kTMSliderControlState_Active
#       mouseDownPosition = NSMakePoint( mousePoint.x - handleControlRect.origin.x, 0)
#       setNeedsDisplay(true)
#     end
#   end
#   
#   
#   def mouseDragged(NSEvent: theEvent)
#     mousePoint = self.convertPoint(theEvent.locationInWindow)
#     hasDragged = false
#     
#     if controlState == kTMSliderControlState_Active
#       newXPosition  = mousePoint.x - mouseDownPosition.x
#       
#       newXPosition = handleControlRectOff.origin.x if newXPosition < handleControlRectOff.origin.x
#       newXPosition = handleControlRectOn.origin.x if newXPosition > handleControlRectOn.origin.x
#       
#       handleControlRect.origin.x  = newXPosition
#       sliderHandleView(setFrame: handleControlRect)
#       setNeedsDisplay(true)
#     end
#   end
#   
#   def mouseUp(NSEvent: theEvent)
#     minimumMovement = 10.0
#     
#     if controlState != kTMSliderControlState_Inactive
#       controlState = kTMSliderControlState_Inactive
#       
#       if !hasDragged
#         setState( !state)
#       elsif state == NSOffState
#         handleControlRect.origin.x > minimumMovement ? setState(NSOnState) : setState(NSOffState)
#       else
#         condition = handleControlRect.origin.x < (bounds.size.width - handleControlRect.size.width - minimumMovement)
#         condition == true ? setState(NSOffState) : setState(NSOnState)
#       end
#     else
#       setState(!state)
#     end  
#   end
#   
#   
#   def performClick(NSEvent: theEvent)
#     mouseDown(NSEvent: theEvent)
#     mouseDragged(NSEvent: theEvent)
#     mouseUp(NSEvent: theEvent)
#   end
#   
#   def state
#     state
#   end 
#   
# end
# 
# 
