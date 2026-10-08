#!/bin/bash
echo "=================================="
echo "    GITHUB PRIVATE SYNC TOOL      "
echo "=================================="
cd ~

if [ ! -d ".git" ]; then
    git init
    git branch -M main
fi

# Remote URL မရှိသေးရင် တောင်းမည်
if ! git remote get-url origin &>/dev/null; then
    read -p "GitHub Repository URL ထည့်ပါ (ဥပမာ https://github.com/username/repo.git): " repo_url
    git remote add origin "$repo_url"
fi

# Git Token credential မရှိသေးရင် Login ဝင်ခိုင်းမည်
if [ ! -f ~/.git-credentials ]; then
    read -p "GitHub Username ထည့်ပါ: " gh_user
    read -p "GitHub Personal Access Token (PAT) ထည့်ပါ: " gh_token
    if [ -n "$gh_user" ] && [ -n "$gh_token" ]; then
        git config --global user.name "$gh_user"
        git config --global user.email "$gh_user@users.noreply.github.com"
        git config --global credential.helper store
        echo "https://$gh_user:$gh_token@github.com" > ~/.git-credentials
        echo "GitHub Login အောင်မြင်စွာ သိမ်းဆည်းပြီးပါပြီ!"
    else
        echo "Username သို့မဟုတ် Token လိုအပ်ပါသည်။"
        exit 1
    fi
fi

git add menu.sh
read -p "Commit Message ထည့်ပါ (ဥပမာ update features): " c_msg
if [ -z "$c_msg" ]; then
    c_msg="Auto update via Wai Lin Yan Tool"
fi
git commit -m "$c_msg"

echo "GitHub သို့ Force Push တင်နေပါပြီ..."
git push -u origin main --force
echo "=================================="
echo "[ ✔ ] GitHub သို့ အောင်မြင်စွာ တင်ပြီးပါပြီ!"
echo "=================================="
