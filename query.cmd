@echo off
cd /d 
git status --untracked-files=all > .status
exit /b %ERRORLEVEL%
