@echo off
setlocal DisableDelayedExpansion

rem Usage: rungit.bat ["Commit message"]
rem Stages every new, modified, and deleted file that Git does not ignore.
pushd "%~dp0"
if errorlevel 1 exit /b 1

git --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Git is not installed or is not available in PATH.
    goto :failed
)

git rev-parse --show-toplevel >nul 2>&1
if errorlevel 1 (
    echo ERROR: This folder is not inside a Git repository.
    goto :failed
)

set "branch="
for /f "delims=" %%B in ('git symbolic-ref --quiet --short HEAD 2^>nul') do set "branch=%%B"
if not defined branch (
    echo ERROR: Check out a branch before uploading.
    goto :failed
)

set "message=%~1"
if not defined message set "message=Update files"

echo Staging all changes...
git add --all
if errorlevel 1 goto :failed

git diff --cached --quiet
if errorlevel 2 goto :failed
if errorlevel 1 (
    git commit -m "%message%"
    if errorlevel 1 goto :failed
) else (
    echo No new changes to commit. Checking for commits to upload...
)

echo Uploading branch %branch% to origin...
git push --set-upstream origin "%branch%"
if errorlevel 1 goto :failed

echo Upload complete.
popd
exit /b 0

:failed
echo ERROR: Upload did not complete. Check the Git error above.
popd
exit /b 1
