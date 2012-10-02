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

-- These fonts used to exist in GMod 12 but were removed in 13.
surface.CreateFont("Trebuchet18", {
	size = 18,
	weight = 500,
	antialias = true,
	shadow = false,
	font = "Trebuchet MS"})
surface.CreateFont("Trebuchet19", {
	size = 19,
	weight = 500,
	antialias = true,
	shadow = false,
	font = "Trebuchet MS"})
surface.CreateFont("Trebuchet20", {
	size = 20,
	weight = 500,
	antialias = true,
	shadow = false,
	font = "Trebuchet MS"})
surface.CreateFont("Trebuchet22", {
	size = 22,
	weight = 500,
	antialias = true,
	shadow = false,
	font = "Trebuchet MS"})
surface.CreateFont("Trebuchet24", {
	size = 24,
	weight = 500,
	antialias = true,
	shadow = false,
	font = "Trebuchet MS"})
surface.CreateFont("TabLarge", {
	size = 17,
	weight = 700,
	antialias = true,
	shadow = false,
	font = "Trebuchet MS"})
surface.CreateFont("UiBold", {
	size = 16,
	weight = 800,
	antialias = true,
	shadow = false,
	font = "Default"})
surface.CreateFont("ScoreboardHeader", {
	size = 32,
	weight = 500,
	antialias = true,
	shadow = false,
	font = "coolvetica"})
surface.CreateFont("ScoreboardSubtitle", {
	size = 22,
	weight = 500,
	antialias = true,
	shadow = false,
	font = "coolvetica"})
surface.CreateFont("ScoreboardPlayerName", {
	size = 19,
	weight = 500,
	antialias = true,
	shadow = false,
	font = "coolvetica"})
surface.CreateFont("ScoreboardPlayerName2", {
	size = 15,
	weight = 500,
	antialias = true,
	shadow = false,
	font = "coolvetica"})
surface.CreateFont("ScoreboardPlayerNameBig", {
	size = 22,
	weight = 500,
	antialias = true,
	shadow = false,
	font = "coolvetica"})