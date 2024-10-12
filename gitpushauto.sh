# Below is safe even with no submodules
git submodule foreach "git pull && git add . && git commit -am 'so far' && git push origin HEAD:main"

git status
git add .
git status

git commit -m "so far"

git push