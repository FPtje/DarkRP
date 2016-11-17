FAdmin.ScoreBoard = FAdmin.ScoreBoard or {}

local ScreenWidth, ScreenHeight = ScrW(), ScrH()

FAdmin.ScoreBoard.X = ScreenWidth * 0.05
FAdmin.ScoreBoard.Y = ScreenHeight * 0.025
FAdmin.ScoreBoard.Width = ScreenWidth * 0.9
FAdmin.ScoreBoard.Height = ScreenHeight * 0.95

FAdmin.ScoreBoard.Controls = FAdmin.ScoreBoard.Controls or {}
FAdmin.ScoreBoard.CurrentView = "Main"

FAdmin.ScoreBoard.Main = FAdmin.ScoreBoard.Main or {}
FAdmin.ScoreBoard.Main.Controls = FAdmin.ScoreBoard.Main.Controls or {}
FAdmin.ScoreBoard.Main.Logo = "gui/gmod_logo"

FAdmin.ScoreBoard.Player = FAdmin.ScoreBoard.Player or {}
FAdmin.ScoreBoard.Player.Controls = FAdmin.ScoreBoard.Player.Controls or {}
FAdmin.ScoreBoard.Player.Player = NULL
FAdmin.ScoreBoard.Player.Logo = "fadmin/back"

FAdmin.ScoreBoard.Server = FAdmin.ScoreBoard.Server or {}
FAdmin.ScoreBoard.Server.Controls = FAdmin.ScoreBoard.Server.Controls or {}
FAdmin.ScoreBoard.Server.Logo = "fadmin/back"
