--- loveui is a love2d library to provide resuable GUI widgets to love2d 
-- developers.

module ("ui", package.seeall)

require "loveui/util/test"
require "loveui/util/class"
require "loveui/util/tag"

style = class()

--- Initiates a style instance.
-- @param tags A string of whitespace separated tags.
-- @param styles A table of key-value style attributes. 
function style:init(tags, styles)
  self.tags = sorttags(tags)
  self.styles = {}
  self.owner = nil
  for k, v in pairs(styles) do
    self.styles[k] = v
  end
  self:compute()
end

--- Compute styles. E.g. borderleftwidth and borderwidth
function style:compute()
  local this = self.styles
  local function default(val, ...)
    for i, v in ipairs({...}) do
      if this[v] == nil then
        this[v] = val
      end
    end
  end
  default(this.bordercolor,
    "borderleftcolor",
    "borderrightcolor",
    "bordertopcolor",
    "borderbottomcolor")
  default(this.borderwidth, 
    "borderleftwidth", 
    "borderrightwidth", 
    "bordertopwidth", 
    "borderbottomwidth")
  default(this.borderradius,
    "bordertopleftradius",
    "bordertoprightradius",
    "borderbottomleftradius",
    "borderbottomrightradius")
  default(this.bordercolor,
    "borderleftcolor",
    "borderrightcolor",
    "bordertopcolor",
    "borderbottomcolor")
  default(this.borderimage,
    "borderleftimage",
    "borderrightimage",
    "bordertopimage",
    "borderbottomimage")
  default(this.bordercornerimage,
    "bordertopleftimage",
    "bordertoprightimage",
    "borderbottomleftimage",
    "borderbottomrightimage")
  default(this.padding,
    "paddingtop",
    "paddingright",
    "paddingleft",
    "paddingbottom")
  default(this.margin,
    "margintop",
    "marginright",
    "marginleft",
    "marginbottom")
  if this.left then this.right = nil end
  if this.top then this.bottom = nil end
  
end

test("ui.style", function()
    local st = style("c a b", {color={0,0,0}})
    return st.tags == "a b c"
  end)
  
test("ui.style", function()
    local st = style("c a b", {color={0,0,0}})
    return #st.styles.color == 3
  end)

return ui
  