sudo rm -r crypto-config/*

sudo rm -r channel-artifacts/*

git add -A

git commit -m "Deleted"

git push

./network-artifacts-gen.sh

git add -A

git commit -m "Generated"

git push
