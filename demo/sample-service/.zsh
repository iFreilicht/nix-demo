# Include the magic
cd ..
. ./demo-setup.sh
cd sample-service

pe "node --version; yarn --version; python3 --version; poetry --version"
# As you can see, nix put us in a shell where not only node, yarn, python and poetry are installed, but
# also all dependencies defined by package.json and pyproject.toml are available. This was a somewhat crude setup,
# both nix and poetry try to be as reproducible as possible, and so the bash shell that we were in didn't
# source any of the rc files it normally would. We can back to my custom zsh config by just launching that.
pe "python3 -c 'import click; print(click.__version__)'"
pe "node -e 'console.log(require("'"'"express"'"'").text)'"
# Python can import its dependencies, and so can node. Splendid!
pe "jq --version && bat --version"
# Additionally, only the added tools override our user profile. The tools we installed before are still available!
# There's a bit of a trap, though:
pe "yarn versions"
# Yarn uses the wrong nodejs version. Nix is so good at isolating, all the packages are isolated from each other!
# In this case, yarn depends on nodejs, and what we install into our dev environment can't change that in any way.
# We have to modify the yarn package itself, and override the input nodejs. Luckily, Nix makes this quite easy.
p "vim flake.nix"
vim flake.nix -s <(../vim/animate-edit.sh ../vim/override-node.vim)
# We have to exit first
pe "exit"