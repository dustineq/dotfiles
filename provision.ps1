# Source our dotFiles/.vimrc
$dotVimPath = "$home\.vimrc"
if (-not (Test-Path $dotVimPath)) {
    Write-Host "Creating default .vimrc at $dotVimPath..."

    $dotVimRCContent = @"
" Autogenerated by provision.ps1
" Prepend the dotfiles directory
set runtimepath^=~/dotFiles/.vim

source ~\dotfiles\.vimrc
"@
    $dotVimRCContent | Out-File -FilePath $dotVimPath -Encoding utf8
} 

Write-Host "Updating plugins..."
vim +PlugInstall +qall
