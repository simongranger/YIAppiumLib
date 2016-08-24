require 'rubygems'
require 'appium_lib'

def WaitTillCompLoaded(compname, maxRetryCount=6, parent=nil, retryInterval=1, verbose=true)
  _count = maxRetryCount
  while _count > 0 do
    begin
      puts "Waiting for #{compname} to load" if verbose
      if parent == nil
        element = find_element(:name, compname)
      else
        element = parent.find_element(:name, compname)
      end
    rescue Selenium::WebDriver::Error::NoSuchElementError
    end
    if element != nil && element.displayed?
        puts "Found #{compname}" if verbose
        return element
    end
    _count -= 1
    sleep (retryInterval)
    #do nothing; retry  
  end
  return nil
end

def WaitTillDisplayed (compname, maxRetryCount=6, retryInterval=1, verbose=false)
    element=WaitTillCompLoaded(compname)
    if element
        begin
          puts "Waiting for #{compname} to be displayed" if verbose
          displayed = element.displayed?
          puts "#{compname} is displayed" if verbose
          return displayed
        rescue Selenium::WebDriver::Error::NoSuchElementError
          _count -= 1
          sleep (retryInterval)
          #do nothing; retry  
        end
    end
    return element
end

def findElementNamed(compname, parent = nil)
    element = WaitTillCompLoaded(compname, 6, parent)
    return element
end

def findElementOfClass(classname, parent = nil)
    element = nil
    begin
        if parent == nil
            sleep (0.2)
            element = find_element(:class, classname)
        else
            sleep (0.2)
            element = parent.find_element(:class, classname)
        end
        return nil if element != nil && !element.displayed?
    rescue Selenium::WebDriver::Error::NoSuchElementError
      #do nothing;  
    end
    return element
end

def findElementsOfClass(classname, parent = nil)
    elements = nil
    begin
        if parent == nil
            elements = find_elements(:class, classname)
        else
            elements = parent.find_elements(:class, classname)
        end
    rescue Selenium::WebDriver::Error::NoSuchElementError
      #do nothing;  
    end
    return elements
end

def ClickButton(btnName, isOptional = false)
    puts "ClickButton #{btnName}".yellow
    button = WaitTillCompLoaded(btnName)
    if button == nil
        puts "Button #{btnName} not found".red
        if !isOptional
            return false
        end
    end
    if button != nil
        button.click
        puts "Button #{btnName} clicked".yellow
        sleep(1)
        return true
    else
        puts "Button #{btnName} not found".red
    end
    return false
end

def ClearNotification(compname, title, supressFailure = true)
    puts "ClearNotification"
    notification=WaitTillCompLoaded(compname, 2)
    if notification != nil
        buttons = nil
        begin
            buttons = findElementsOfClass('CYIPushButtonView', notification)
        rescue Selenium::WebDriver::Error::NoSuchElementError
            #do nothing
        end
        if buttons != nil
            for button in buttons
                buttonName = findElementNamed('Text', button)
                if buttonName != nil && buttonName.text == title
                    button.click
                    puts "Cleared Notification"
                    return true
                end
            end
        end
    end
    if !supressFailure
        puts "Expected #{title} button not found in #{compname}".red
    end
    return supressFailure
end

def CheckNotification(compname, title)
    notification=WaitTillCompLoaded(compname)
    sleep(1)
    if notification != nil
        titlefield = findElementNamed('Title-Text', notification)
        if (titlefield.text == title)
            return true
        end
    end
    return false
end

# To use relative find option it could be called as follows
# targetUiElement = FindChildOf(:class, 'SettingsView', :name, 'Btn-Back')
def FindChildOf(parentByStrat, parentIdentifier, childByStrat, childIdentifier)
    parent = find_element(parentByStrat, parentIdentifier)
    return nil if parent==nil
    return parent.find_element(childByStrat, childIdentifier)
end

# To use relative find option it could be called as follows
# targetUiElement = FindChildOf(:class, 'SettingsView', :name, 'Btn-Back')
def ClickDropDownButton(buttonName)
    dropdown = findElementNamed("Filter-Drop-Down")
    buttons = dropdown.find_elements(:name, "Placeholder-Text")
    return false if buttons == nil
    for button in buttons
        puts "trying button named #{button.text}"
        if button.text == buttonName
            button.click
            puts "Clicked #{button.text}"
            return true
        end
    end
    return false
end

def WaitForTextFieldWithValue(textfield, value, maxRetryCount=6, retryInterval=1)
    _count = maxRetryCount
    while _count > 0 do
        return true if textfield.text == value
        _count -= 1
        sleep (retryInterval)
        #do nothing; retry  
    end
    return false
end

# Convenience method to peform a swipe.
    #
    # Note that iOS 7 simulators have broken swipe.
    #
    # @option opts [int] :start_x Where to start swiping, on the x axis.  Default 0.
    # @option opts [int] :start_y Where to start swiping, on the y axis.  Default 0.
    # @option opts [int] :end_x Where to end swiping, on the x axis.  Default 0.
    # @option opts [int] :end_y Where to end swiping, on the y axis.  Default 0.
    # @option opts [int] :duration How long the actual swipe takes to complete in milliseconds. Default 200.
    # e.g  swipe(:start_x=>754, :start_y=>718, :end_x=>347, :end_y=>679)
def swipe(opts)
  start_x  = opts.fetch :start_x, 0
  start_y  = opts.fetch :start_y, 0
  end_x    = opts.fetch :end_x, 0
  end_y    = opts.fetch :end_y, 0
  duration = opts.fetch :duration, 2

  
  action = Appium::TouchAction.new.press(x: start_x, y: start_y).move_to(x: end_x, y: end_y).release 
  action.perform
end