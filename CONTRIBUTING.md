# THE GITHUB ISSUES PAGE IS NOT FOR GETTING HELP!
Remember that! We've got a Discord for that kind of stuff. It can be found here:
https://darkrp.page.link/discord

# What to do when you have a problem in DarkRP

There are three kinds of problems that can happen in DarkRP:
- The problem caused by the end user (think of a bad modification or a bad setting)
- The problem caused by a mod for DarkRP (think of a weapon pack, model pack or extra money printers or things like that)
- The problem for which the developer of DarkRP is responsible

The very first step of solving your problem is figuring out who caused it. Often this is easy to figure out. If DarkRP started to error
when you edited your HUD, it's probably your fault (or the server host's). If the server starts in sandbox, or if you get the error

```
"couldn't include file <ANYTHING> (File not found)"
```

it's your fault. Did you try uploading the entire unzipped DarkRP folder to the server with FileZilla? That's a known problem, it's FileZilla's fault. Half of your files didn't upload properly.

When a weapon from a weapon pack does crazy things, it's probably the person who made that weapon pack.
When the problem occurs with unedited DarkRP features, it might be DarkRP's fault.
There are cases for which it might be difficult to determine who is responsible for the problem.
In these cases you should look at the errors that usually show up. The errors usually say which mod caused the problem.

If it's your fault, blame yourself. If you caused a problem you don't know how to solve, you have two options:
<ol>
<li>ask on a forum or ask your friends for help. If you contact mod developers, they might get mad at you for being asked something they have nothing to do with</li>
<li>undo the change that broke DarkRP. To do this, always make sure you have a backup</li>
</ol>

If it's the fault of a third party mod developer, contact them to report the bug. They are the only ones who can (and are willing to)
solve the problems caused by their mod.


# Reporting a bug for DarkRP
Only report bugs for issues of which you are VERY SURE that it is the fault of DarkRP developers.

To report a bug for DarkRP, you need to follow very strict rules. These rules exist so the bugs can be easily identified and solved.

The most important rules are:
<ol>
<li>Do not ask for help. Your need of help is not the fault of DarkRP.</li>
<li>Do not report an issue when you are unable to install DarkRP.</li>
<li>Do not report problems that you caused yourself.</li>
<li>Do not report problems for other mods.</li>
<li>Do not report problems for a server that you do not own or develop for</li>
<li>Do not report a problem that has been reported before (you can search on the bug reporting site)</li>
<li>Do not repost your problem when your previous problem has been closed. You can post in a closed issue and you will still be listened to.</li>
<li>Never just post "It doesn't work" that's no information to work on.</li>
</ol>

Failure to abide by these rules will get your report closed and/or your account banned from reporting issues.

How to report a bug:
<ol>
<li> Enter lua_log_sv 1 in RCon or the server console</li>
<li> Make the problem happen</li>
	if a weapon messes up when you shoot, shoot the weapon.
	if it happens on server start, change level or restart the server
	if it happens when the mayor tries to place a lawboard, make the mayor try to spawn a lawboard
	etc.</li>
<li> Go to the FTP of your server.</li>
<li> In the garrysmod/ folder you should see "lua_errors_server.txt" and/or "clientside_errors.txt"
 	upload the contents of BOTH these files to www.pastebin.com
 	if you don't see those files, make sure you did everything right (lua_log_sv must be 1).
 	if you don't see the files and you're sure that you did the logging right, mention this in the bug report:
 	"No error log files were generated."
 	If you only see one file, upload that one file to www.pastebin.com and mention the following in the bug report:
 	"The other error log file was not generated."
 	Thanks. Errors help A LOT.</li>
<li> Go to https://github.com/FPtje/DarkRP/issues/new (DON'T SKIP THE PREVIOUS STEPS)</li>
<li> Think of an appropriate title. Try to be specific here</li>
<li> Take the issue template from "github issue template.txt", which is in the HELP folder, and copy paste it into the "Write" field.</li>
<li> Fill it in, try not to leave anything empty!</li>
	MORE information = MUCH HIGHER chance that the problem will be solved
<li> Click "Submit new issue"</li>
</ol>
