# loveui #

## Document ##
This document describes the loveui library when its implementation is complete.

## Purpose ##
To create a set of GUI widgets for love2d developers. The widgets should be easily customized and not fixed to a theme. The code for adding and styling widgets should be as concise and easy to read as possible.

## Concepts ##
loveui is a set of widgets.

A widget could be a button, a textfield, a progress bar, etc. It can also be a rectangle.

A widget can have widgets within it. E.g. A rectangle containing a progress bar.

There is a widget that is the top most widget, which catches mouse and key events and passes them along. It is the `context` widget.

To add a widget:
    widget1:add(widget2)
    
To remove,
    widget1:remove(widget2)

Widgets' appearance are described by `style`s. 

A widget is tagged by multiple strings. loveui widgets are tagged with their own classes' names. E.g. ui.button widget instances are always tagged with "ui.button". When the mouse is hovering over it, it is tagged with "ui.button" and "ui.hover", as well.

Every style has a "selector" - A string of tags separated by whitespace. The style will apply to widgets that contain all of the tags in side the "selector".

To add a style:
    widget:1add(style1)

To remove,
    widget1:remove(widget2)
    
When a style is added to a widget, it can only ever apply to sub-widgets of that widget, irrespective of what is tagged with what and what tags are in the selector. It cannot apply to the widget you added to either; sub-widgets and their sub-widgets and their sub-widgets... only.

Once you add a style, even if you remove the widgets the style applies to and add them back again as sub-widgets, the style is still there and will still apply, similar to HTML elements and CSS styles.

Widgets' actions are described by callback functions.

There are several type of triggers that will invoke callback functions.

    click         -- When mouse pressed on the widget, and released on 
                     the widget.
    change        -- When the value of the widget changes.
    focus         -- When the widget is focused by mouse or tab.
    blur          -- When the widget loses focus.
    mousedown     -- When the mouse is pressed down on the widget.
    mouseenter    -- When the mouse hovers into a widget.
    mouseleave    -- When the mouse hovers out of a widget.
    keypress      -- When a key is pressed and released while widget is 
                     focused.
    keyup         -- When a key is released while widget is focused.
    keydown       -- When a key is pressed while widget is focused.

To add a callback function for e.g. mousedown:
    widget1:onmousedown(function(self, x, y, button) end)

Just add 'on' prefix to one of the trigger names and call it on the widget to add a callback for that trigger.

Note that the function returns widget1. See Example Code section.

## Example Code ##

    function love.load()
      context:add(
        -- Add a style that applies to all `ui.button`s tagged with 
        -- "tag".
        ui.style("ui.button tag", {
            left = 100, top = 100, 
            width = 50, height = 50,
            bordercolor = {255,255,0,255},
            borderwidth = 1,
            backgroundcolor = {255, 255, 255, 255}, 
            backgroundimage = "./button.png"}),
         
        -- Add a button that prints when mouse press or clicks on it.
        -- Its label is "Click".
        ui.button("tag tag2 tag3", {value = "Click"})
          :onmousedown( 
          function(self, x, y, button)
            print("mousedown", x, y, button)
          end)
          :onclick(
          function(self, x, y, button)
            print("click", x, y, button)
          end))
    end

## Reference ##

### ui.style attributes ###
* ones are not implemented yet.

    left
    top
    
    width
    height
    
    color
    font
    selectioncolor    

    backgroundcolor
    *backgroundimage
    *backgroundrepeat
    *backgroundposition
    
    borderwidth
    borderleftwidth
    borderrightwidth
    bordertopwidth
    borderbottomwidth
    
    borderradius
    bordertopleftradius
    bordertoprightradius
    borderbottomleftradius
    borderbottomrightradius
    
    bordercolor
    borderleftcolor
    bordertopcolor
    borderrightcolor
    borderbottomcolor
    
    *borderimage
    
    *padding
    *paddingtop
    *paddingright
    *paddingleft
    *paddingbottom

### widget triggers ###

    onclick
    onchange
    onfocus
    onblur
    onmouseover

### invoke widget triggers ###

    click(x, y)
    change("content")
    focus()
    blur()
    mouseover(x, y, dx, dy)

### built-in tags ###

    ui.hover
    
    ui.view
    
    ui.context
    ui.button
    ui.label
    ui.textfield
    ui.progressbar
    ui.frame

### widget interface ###

    :add(style/widget/tag)
    :remove(style/widget/tag)
    :owns(style/widget/tag)
    :apply(attributes)
    :get(tags)
