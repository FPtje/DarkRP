FAdmin.ScoreBoard = {}

local ScreenWidth, ScreenHeight = ScrW(), ScrH()

FAdmin.ScoreBoard.X = ScreenWidth * 0.05
FAdmin.ScoreBoard.Y = ScreenHeight * 0.025
FAdmin.ScoreBoard.Width = ScreenWidth * 0.9
FAdmin.ScoreBoard.Height = ScreenHeight * 0.95

FAdmin.ScoreBoard.Controls = {}
FAdmin.ScoreBoard.CurrentView = "Main"

FAdmin.ScoreBoard.Main = {}
FAdmin.ScoreBoard.Main.Controls = {}
FAdmin.ScoreBoard.Main.Logo = "gui/gmod_logo"

FAdmin.ScoreBoard.Player = {}
FAdmin.ScoreBoard.Player.Controls = {}
FAdmin.ScoreBoard.Player.Player = NULL
FAdmin.ScoreBoard.Player.Logo = "FAdmin/back"

FAdmin.ScoreBoard.Server = {}
FAdmin.ScoreBoard.Server.Controls = {}
FAdmin.ScoreBoard.Server.Logo = "FAdmin/back"

FAdmin.ScoreBoard.Help = {}
FAdmin.ScoreBoard.Help.Controls = {}
FAdmin.ScoreBoard.Help.Logo = "FAdmin/back"