# Check if it's first login of the day
if [ ! -f "/home/jay/.first_login" ]; then
  touch "/home/jay/.first_login"
  ~/scripts/login/first_login.sh
fi
