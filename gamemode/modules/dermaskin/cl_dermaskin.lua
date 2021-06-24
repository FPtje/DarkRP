-- Skin for DarkRP gui's
SKIN = {}

SKIN.PrintName          = "DarkRP"
SKIN.Author             = "FPtje Falco"
SKIN.DermaVersion       = 1
SKIN.GwenTexture        = Material("darkrp/darkrpderma.png")


SKIN.colTextEntryText               = Color(255, 255, 255)
SKIN.colTextEntryTextCursor         = Color(255, 255, 255)

SKIN.colTextEntryTextPlaceholder    = Color(200, 200, 200, 200) -- Unofficial but will probably be named this

SKIN.tex = {}

SKIN.tex.Selection                  = GWEN.CreateTextureBorder(384, 32, 31, 31, 4, 4, 4, 4)

SKIN.tex.Panels = {}
SKIN.tex.Panels.Normal              = GWEN.CreateTextureBorder(256, 0, 63, 63, 16, 16, 16, 16)
SKIN.tex.Panels.Bright              = GWEN.CreateTextureBorder(256 + 64, 0, 63, 63, 16, 16, 16, 16)
SKIN.tex.Panels.Dark                = GWEN.CreateTextureBorder(256, 64, 63, 63, 16, 16, 16, 16)
SKIN.tex.Panels.Highlight           = GWEN.CreateTextureBorder(256 + 64, 64, 63, 63, 16, 16, 16, 16)

SKIN.tex.Button                     = GWEN.CreateTextureBorder(480, 0, 31, 31, 8, 8, 8, 8)
SKIN.tex.Button_Hovered             = GWEN.CreateTextureBorder(480, 32, 31, 31, 8, 8, 8, 8)
SKIN.tex.Button_Dead                = GWEN.CreateTextureBorder(480, 64, 31, 31, 8, 8, 8, 8)
SKIN.tex.Button_Down                = GWEN.CreateTextureBorder(480, 96, 31, 31, 8, 8, 8, 8)
SKIN.tex.Shadow                     = GWEN.CreateTextureBorder(448, 0, 31, 31, 8, 8, 8, 8)

SKIN.tex.Tree                       = GWEN.CreateTextureBorder(256, 128, 127, 127, 16, 16, 16, 16)
SKIN.tex.Checkbox_Checked           = GWEN.CreateTextureNormal(448, 32, 15, 15)
SKIN.tex.Checkbox                   = GWEN.CreateTextureNormal(464, 32, 15, 15)
SKIN.tex.CheckboxD_Checked          = GWEN.CreateTextureNormal(448, 48, 15, 15)
SKIN.tex.CheckboxD                  = GWEN.CreateTextureNormal(464, 48, 15, 15)
--SKIN.tex.RadioButton_Checked      = GWEN.CreateTextureNormal(448, 64, 15, 15)
--SKIN.tex.RadioButton              = GWEN.CreateTextureNormal(464, 64, 15, 15)
--SKIN.tex.RadioButtonD_Checked     = GWEN.CreateTextureNormal(448, 80, 15, 15)
--SKIN.tex.RadioButtonD             = GWEN.CreateTextureNormal(464, 80, 15, 15)
SKIN.tex.TreePlus                   = GWEN.CreateTextureNormal(448, 96, 15, 15)
SKIN.tex.TreeMinus                  = GWEN.CreateTextureNormal(464, 96, 15, 15)
--SKIN.tex.Menu_Strip               = GWEN.CreateTextureBorder(0, 128, 127, 21, 1, 1, 1, 1)
SKIN.tex.TextBox                    = GWEN.CreateTextureBorder(0, 150, 127, 21, 4, 4, 4, 4)
SKIN.tex.TextBox_Focus              = GWEN.CreateTextureBorder(0, 172, 127, 21, 4, 4, 4, 4)
SKIN.tex.TextBox_Disabled           = GWEN.CreateTextureBorder(0, 193, 127, 21, 4, 4, 4, 4)
SKIN.tex.MenuBG_Margin              = GWEN.CreateTextureBorder(128, 128, 127, 63, 24, 8, 8, 8)
SKIN.tex.MenuBG                     = GWEN.CreateTextureBorder(128, 192, 127, 63, 8, 8, 8, 8)
SKIN.tex.MenuBG_Hover               = GWEN.CreateTextureBorder(128, 256, 127, 31, 8, 8, 8, 8)
SKIN.tex.MenuBG_Spacer              = GWEN.CreateTextureNormal(128, 288, 127, 3)
SKIN.tex.Tab_Control                = GWEN.CreateTextureBorder(0, 256, 127, 127, 8, 8, 8, 8)
SKIN.tex.TabB_Active                = GWEN.CreateTextureBorder(0, 416, 63, 31, 8, 8, 8, 8)
SKIN.tex.TabB_Inactive              = GWEN.CreateTextureBorder(0 + 128, 416, 63, 31, 8, 8, 8, 8)
SKIN.tex.TabT_Active                = GWEN.CreateTextureBorder(0, 384, 63, 31, 8, 8, 8, 8)
SKIN.tex.TabT_Inactive              = GWEN.CreateTextureBorder(0 + 128, 384, 63, 31, 8, 8, 8, 8)
SKIN.tex.TabL_Active                = GWEN.CreateTextureBorder(64, 384, 31, 63, 8, 8, 8, 8)
SKIN.tex.TabL_Inactive              = GWEN.CreateTextureBorder(64 + 128, 384, 31, 63, 8, 8, 8, 8)
SKIN.tex.TabR_Active                = GWEN.CreateTextureBorder(96, 384, 31, 63, 8, 8, 8, 8)
SKIN.tex.TabR_Inactive              = GWEN.CreateTextureBorder(96 + 128, 384, 31, 63, 8, 8, 8, 8)
SKIN.tex.Tab_Bar                    = GWEN.CreateTextureBorder(128, 352, 127, 31, 4, 4, 4, 4)

SKIN.tex.Window = {}

SKIN.tex.Window.Normal              = GWEN.CreateTextureBorder(0, 0, 127, 127, 8, 32, 8, 8)
SKIN.tex.Window.Inactive            = GWEN.CreateTextureBorder(128, 0, 127, 127, 8, 32, 8, 8)
SKIN.tex.Window.Close               = GWEN.CreateTextureNormal(0, 224, 24, 24)
SKIN.tex.Window.Close_Hover         = GWEN.CreateTextureNormal(32, 224, 24, 24)
SKIN.tex.Window.Close_Down          = GWEN.CreateTextureNormal(64, 224, 24, 24)
SKIN.tex.Window.Close_Disabled      = GWEN.CreateTextureNormal(96, 224, 24, 24)

SKIN.tex.Window.Maxi                = GWEN.CreateTextureNormal(32 + 96 * 2, 448, 31, 31)
SKIN.tex.Window.Maxi_Hover          = GWEN.CreateTextureNormal(64 + 96 * 2, 448, 31, 31)
SKIN.tex.Window.Maxi_Down           = GWEN.CreateTextureNormal(96 + 96 * 2, 448, 31, 31)

SKIN.tex.Window.Restore             = GWEN.CreateTextureNormal(32 + 96 * 2, 448 + 32, 31, 31)
SKIN.tex.Window.Restore_Hover       = GWEN.CreateTextureNormal(64 + 96 * 2, 448 + 32, 31, 31)
SKIN.tex.Window.Restore_Down        = GWEN.CreateTextureNormal(96 + 96 * 2, 448 + 32, 31, 31)

SKIN.tex.Window.Mini                = GWEN.CreateTextureNormal(32 + 96, 448, 31, 31)
SKIN.tex.Window.Mini_Hover          = GWEN.CreateTextureNormal(64 + 96, 448, 31, 31)
SKIN.tex.Window.Mini_Down           = GWEN.CreateTextureNormal(96 + 96, 448, 31, 31)

SKIN.tex.Scroller = {}
SKIN.tex.Scroller.TrackV                = GWEN.CreateTextureBorder(384, 208, 15, 127, 4, 4, 4, 4)
SKIN.tex.Scroller.ButtonV_Normal        = GWEN.CreateTextureBorder(384 + 16, 208, 15, 127, 4, 4, 4, 4)
SKIN.tex.Scroller.ButtonV_Hover         = GWEN.CreateTextureBorder(384 + 32, 208, 15, 127, 4, 4, 4, 4)
SKIN.tex.Scroller.ButtonV_Down          = GWEN.CreateTextureBorder(384 + 48, 208, 15, 127, 4, 4, 4, 4)
SKIN.tex.Scroller.ButtonV_Disabled      = GWEN.CreateTextureBorder(384 + 64, 208, 15, 127, 4, 4, 4, 4)

SKIN.tex.Scroller.TrackH                = GWEN.CreateTextureBorder(384, 128, 127, 15, 4, 4, 4, 4)
SKIN.tex.Scroller.ButtonH_Normal        = GWEN.CreateTextureBorder(384, 128 + 16, 127, 15, 4, 4, 4, 4)
SKIN.tex.Scroller.ButtonH_Hover         = GWEN.CreateTextureBorder(384, 128 + 32, 127, 15, 4, 4, 4, 4)
SKIN.tex.Scroller.ButtonH_Down          = GWEN.CreateTextureBorder(384, 128 + 48, 127, 15, 4, 4, 4, 4)
SKIN.tex.Scroller.ButtonH_Disabled      = GWEN.CreateTextureBorder(384, 128 + 64, 127, 15, 4, 4, 4, 4)

SKIN.tex.Scroller.LeftButton_Normal     = GWEN.CreateTextureBorder(464, 208, 15, 15, 2, 2, 2, 2)
SKIN.tex.Scroller.LeftButton_Hover      = GWEN.CreateTextureBorder(480, 208, 15, 15, 2, 2, 2, 2)
SKIN.tex.Scroller.LeftButton_Down       = GWEN.CreateTextureBorder(464, 272, 15, 15, 2, 2, 2, 2)
SKIN.tex.Scroller.LeftButton_Disabled   = GWEN.CreateTextureBorder(480 + 48, 272, 15, 15, 2, 2, 2, 2)

SKIN.tex.Scroller.UpButton_Normal       = GWEN.CreateTextureBorder(464, 208 + 16, 15, 15, 2, 2, 2, 2)
SKIN.tex.Scroller.UpButton_Hover        = GWEN.CreateTextureBorder(480, 208 + 16, 15, 15, 2, 2, 2, 2)
SKIN.tex.Scroller.UpButton_Down         = GWEN.CreateTextureBorder(464, 272 + 16, 15, 15, 2, 2, 2, 2)
SKIN.tex.Scroller.UpButton_Disabled     = GWEN.CreateTextureBorder(480 + 48, 272 + 16, 15, 15, 2, 2, 2, 2)

SKIN.tex.Scroller.RightButton_Normal    = GWEN.CreateTextureBorder(464, 208 + 32, 15, 15, 2, 2, 2, 2)
SKIN.tex.Scroller.RightButton_Hover     = GWEN.CreateTextureBorder(480, 208 + 32, 15, 15, 2, 2, 2, 2)
SKIN.tex.Scroller.RightButton_Down      = GWEN.CreateTextureBorder(464, 272 + 32, 15, 15, 2, 2, 2, 2)
SKIN.tex.Scroller.RightButton_Disabled  = GWEN.CreateTextureBorder(480 + 48, 272 + 32, 15, 15, 2, 2, 2, 2)

SKIN.tex.Scroller.DownButton_Normal     = GWEN.CreateTextureBorder(464, 208 + 48, 15, 15, 2, 2, 2, 2)
SKIN.tex.Scroller.DownButton_Hover      = GWEN.CreateTextureBorder(480, 208 + 48, 15, 15, 2, 2, 2, 2)
SKIN.tex.Scroller.DownButton_Down       = GWEN.CreateTextureBorder(464, 272 + 48, 15, 15, 2, 2, 2, 2)
SKIN.tex.Scroller.DownButton_Disabled   = GWEN.CreateTextureBorder(480 + 48, 272 + 48, 15, 15, 2, 2, 2, 2)

SKIN.tex.Menu = {}
SKIN.tex.Menu.RightArrow                = GWEN.CreateTextureNormal(464, 112, 15, 15)

SKIN.tex.Input = {}
SKIN.tex.Input.ListBox                  = GWEN.CreateTextureBorder(256, 256, 63, 127, 8, 8, 8, 8)

SKIN.tex.Input.ComboBox = {}
SKIN.tex.Input.ComboBox.Normal          = GWEN.CreateTextureBorder(384, 336, 127, 31, 8, 8, 32, 8)
SKIN.tex.Input.ComboBox.Hover           = GWEN.CreateTextureBorder(384, 336 + 32, 127, 31, 8, 8, 32, 8)
SKIN.tex.Input.ComboBox.Down            = GWEN.CreateTextureBorder(384, 336 + 64, 127, 31, 8, 8, 32, 8)
SKIN.tex.Input.ComboBox.Disabled        = GWEN.CreateTextureBorder(384, 336 + 96, 127, 31, 8, 8, 32, 8)

SKIN.tex.Input.ComboBox.Button = {}
SKIN.tex.Input.ComboBox.Button.Normal        = GWEN.CreateTextureNormal(496, 272, 15, 15)
SKIN.tex.Input.ComboBox.Button.Hover         = GWEN.CreateTextureNormal(496, 272 + 16, 15, 15)
SKIN.tex.Input.ComboBox.Button.Down          = GWEN.CreateTextureNormal(496, 272 + 32, 15, 15)
SKIN.tex.Input.ComboBox.Button.Disabled      = GWEN.CreateTextureNormal(496, 272 + 48, 15, 15)

SKIN.tex.Input.UpDown = {}
SKIN.tex.Input.UpDown.Up = {}
SKIN.tex.Input.UpDown.Up.Normal             = GWEN.CreateTextureCentered(384, 112, 7, 7)
SKIN.tex.Input.UpDown.Up.Hover              = GWEN.CreateTextureCentered(384 + 8, 112, 7, 7)
SKIN.tex.Input.UpDown.Up.Down               = GWEN.CreateTextureCentered(384 + 16, 112, 7, 7)
SKIN.tex.Input.UpDown.Up.Disabled           = GWEN.CreateTextureCentered(384 + 24, 112, 7, 7)

SKIN.tex.Input.UpDown.Down = {}
SKIN.tex.Input.UpDown.Down.Normal           = GWEN.CreateTextureCentered(384, 120, 7, 7)
SKIN.tex.Input.UpDown.Down.Hover            = GWEN.CreateTextureCentered(384 + 8, 120, 7, 7)
SKIN.tex.Input.UpDown.Down.Down             = GWEN.CreateTextureCentered(384 + 16, 120, 7, 7)
SKIN.tex.Input.UpDown.Down.Disabled         = GWEN.CreateTextureCentered(384 + 24, 120, 7, 7)

SKIN.tex.Input.Slider = {}
SKIN.tex.Input.Slider.H = {}
SKIN.tex.Input.Slider.H.Normal          = GWEN.CreateTextureNormal(416, 32, 15, 15)
SKIN.tex.Input.Slider.H.Hover           = GWEN.CreateTextureNormal(416, 32 + 16, 15, 15)
SKIN.tex.Input.Slider.H.Down            = GWEN.CreateTextureNormal(416, 32 + 32, 15, 15)
SKIN.tex.Input.Slider.H.Disabled        = GWEN.CreateTextureNormal(416, 32 + 48, 15, 15)

SKIN.tex.Input.Slider.V = {}
SKIN.tex.Input.Slider.V.Normal          = GWEN.CreateTextureNormal(416 + 16, 32, 15, 15)
SKIN.tex.Input.Slider.V.Hover           = GWEN.CreateTextureNormal(416 + 16, 32 + 16, 15, 15)
SKIN.tex.Input.Slider.V.Down            = GWEN.CreateTextureNormal(416 + 16, 32 + 32, 15, 15)
SKIN.tex.Input.Slider.V.Disabled        = GWEN.CreateTextureNormal(416 + 16, 32 + 48, 15, 15)

SKIN.tex.Input.ListBox = {}
SKIN.tex.Input.ListBox.Background           = GWEN.CreateTextureBorder(256, 256, 63, 127, 8, 8, 8, 8)
SKIN.tex.Input.ListBox.Hovered          = GWEN.CreateTextureBorder(320, 320, 31, 31, 8, 8, 8, 8)
SKIN.tex.Input.ListBox.EvenLine         = GWEN.CreateTextureBorder(352, 256, 31, 31, 8, 8, 8, 8)
SKIN.tex.Input.ListBox.OddLine          = GWEN.CreateTextureBorder(352, 288, 31, 31, 8, 8, 8, 8)
SKIN.tex.Input.ListBox.EvenLineSelected         = GWEN.CreateTextureBorder(320, 270, 31, 31, 8, 8, 8, 8)
SKIN.tex.Input.ListBox.OddLineSelected          = GWEN.CreateTextureBorder(320, 288, 31, 31, 8, 8, 8, 8)

SKIN.tex.ProgressBar = {}
SKIN.tex.ProgressBar.Back       = GWEN.CreateTextureBorder(384, 0, 31, 31, 8, 8, 8, 8)
SKIN.tex.ProgressBar.Front      = GWEN.CreateTextureBorder(384 + 32, 0, 31, 31, 8, 8, 8, 8)


SKIN.tex.CategoryList = {}
SKIN.tex.CategoryList.Outer     = GWEN.CreateTextureBorder(256, 384, 63, 63, 8, 8, 8, 8)
SKIN.tex.CategoryList.Inner     = GWEN.CreateTextureBorder(256 + 64, 384, 63, 63, 8, 21, 8, 8)
SKIN.tex.CategoryList.Header    = GWEN.CreateTextureBorder(320, 352, 63, 31, 8, 8, 8, 8)

SKIN.tex.Tooltip                = GWEN.CreateTextureBorder(384, 64, 31, 31, 8, 8, 8, 8)

SKIN.Colours = {}

SKIN.Colours.Window = {}
SKIN.Colours.Window.TitleActive         = GWEN.TextureColor(4 + 8 * 0, 508)
SKIN.Colours.Window.TitleInactive       = GWEN.TextureColor(4 + 8 * 1, 508)

SKIN.Colours.Button = {}
SKIN.Colours.Button.Normal              = GWEN.TextureColor(4 + 8 * 2, 508)
SKIN.Colours.Button.Hover               = GWEN.TextureColor(4 + 8 * 3, 508)
SKIN.Colours.Button.Down                = GWEN.TextureColor(4 + 8 * 2, 500)
SKIN.Colours.Button.Disabled            = GWEN.TextureColor(4 + 8 * 3, 500)

SKIN.Colours.Tab = {}
SKIN.Colours.Tab.Active = {}
SKIN.Colours.Tab.Active.Normal          = GWEN.TextureColor(4 + 8 * 4, 508)
SKIN.Colours.Tab.Active.Hover           = GWEN.TextureColor(4 + 8 * 5, 508)
SKIN.Colours.Tab.Active.Down            = GWEN.TextureColor(4 + 8 * 4, 500)
SKIN.Colours.Tab.Active.Disabled        = GWEN.TextureColor(4 + 8 * 5, 500)

SKIN.Colours.Tab.Inactive = {}
SKIN.Colours.Tab.Inactive.Normal        = GWEN.TextureColor(4 + 8 * 6, 508)
SKIN.Colours.Tab.Inactive.Hover         = GWEN.TextureColor(4 + 8 * 7, 508)
SKIN.Colours.Tab.Inactive.Down          = GWEN.TextureColor(4 + 8 * 6, 500)
SKIN.Colours.Tab.Inactive.Disabled      = GWEN.TextureColor(4 + 8 * 7, 500)

SKIN.Colours.Label = {}
SKIN.Colours.Label.Default              = GWEN.TextureColor(4 + 8 * 8, 508)
SKIN.Colours.Label.Bright               = GWEN.TextureColor(4 + 8 * 9, 508)
SKIN.Colours.Label.Dark                 = GWEN.TextureColor(4 + 8 * 8, 500)
SKIN.Colours.Label.Highlight            = GWEN.TextureColor(4 + 8 * 9, 500)

SKIN.Colours.Tree = {}
SKIN.Colours.Tree.Lines                 = GWEN.TextureColor(4 + 8 * 10, 508)
---- !!!
SKIN.Colours.Tree.Normal                = GWEN.TextureColor(4 + 8 * 11, 508)
SKIN.Colours.Tree.Hover                 = GWEN.TextureColor(4 + 8 * 10, 500)
SKIN.Colours.Tree.Selected              = GWEN.TextureColor(4 + 8 * 11, 500)

SKIN.Colours.Properties = {}
SKIN.Colours.Properties.Line_Normal         = GWEN.TextureColor(4 + 8 * 12, 508)
SKIN.Colours.Properties.Line_Selected       = GWEN.TextureColor(4 + 8 * 13, 508)
SKIN.Colours.Properties.Line_Hover          = GWEN.TextureColor(4 + 8 * 12, 500)
SKIN.Colours.Properties.Title               = GWEN.TextureColor(4 + 8 * 13, 500)
SKIN.Colours.Properties.Column_Normal       = GWEN.TextureColor(4 + 8 * 14, 508)
SKIN.Colours.Properties.Column_Selected     = GWEN.TextureColor(4 + 8 * 15, 508)
SKIN.Colours.Properties.Column_Hover        = GWEN.TextureColor(4 + 8 * 14, 500)
SKIN.Colours.Properties.Border              = GWEN.TextureColor(4 + 8 * 15, 500)
SKIN.Colours.Properties.Label_Normal        = GWEN.TextureColor(4 + 8 * 16, 508)
SKIN.Colours.Properties.Label_Selected      = GWEN.TextureColor(4 + 8 * 17, 508)
SKIN.Colours.Properties.Label_Hover         = GWEN.TextureColor(4 + 8 * 16, 500)

SKIN.Colours.Category = {}
SKIN.Colours.Category.Header                = GWEN.TextureColor(4 + 8 * 18, 500)
SKIN.Colours.Category.Header_Closed         = GWEN.TextureColor(4 + 8 * 19, 500)
SKIN.Colours.Category.Line = {}
SKIN.Colours.Category.Line.Text             = GWEN.TextureColor(4 + 8 * 20, 508)
SKIN.Colours.Category.Line.Text_Hover       = GWEN.TextureColor(4 + 8 * 21, 508)
SKIN.Colours.Category.Line.Text_Selected    = GWEN.TextureColor(4 + 8 * 20, 500)
SKIN.Colours.Category.Line.Button           = GWEN.TextureColor(4 + 8 * 21, 500)
SKIN.Colours.Category.Line.Button_Hover     = GWEN.TextureColor(4 + 8 * 22, 508)
SKIN.Colours.Category.Line.Button_Selected  = GWEN.TextureColor(4 + 8 * 23, 508)
SKIN.Colours.Category.LineAlt = {}
SKIN.Colours.Category.LineAlt.Text              = GWEN.TextureColor(4 + 8 * 22, 500)
SKIN.Colours.Category.LineAlt.Text_Hover        = GWEN.TextureColor(4 + 8 * 23, 500)
SKIN.Colours.Category.LineAlt.Text_Selected     = GWEN.TextureColor(4 + 8 * 24, 508)
SKIN.Colours.Category.LineAlt.Button            = GWEN.TextureColor(4 + 8 * 25, 508)
SKIN.Colours.Category.LineAlt.Button_Hover      = GWEN.TextureColor(4 + 8 * 24, 500)
SKIN.Colours.Category.LineAlt.Button_Selected   = GWEN.TextureColor(4 + 8 * 25, 500)

derma.DefineSkin("DarkRP", "The official SKIN for DarkRP", SKIN)
