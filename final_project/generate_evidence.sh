#!/bin/bash
# Usage: ./generate_evidence.sh YOUR-GITHUB-USERNAME
# Run from inside final_project while the server is running (npm start).
GH_USER="$1"
if [ -z "$GH_USER" ]; then echo "Usage: ./generate_evidence.sh YOUR-GITHUB-USERNAME"; exit 1; fi
B=http://localhost:5000
mkdir -p evidence

run() { # name, command string
  { echo "Command:"; echo "$2"; echo; echo "Output:"; eval "$2"; echo; } > "evidence/$1"
  echo "Saved evidence/$1"
}

run githubrepo       "curl -s https://api.github.com/repos/$GH_USER/expressBookReviews | python3 -m json.tool"
run getallbooks      "curl -s $B/"
run getbooksbyISBN   "curl -s $B/isbn/1"
run getbooksbyauthor "curl -s $B/author/Chinua%20Achebe"
run getbooksbytitle  "curl -s $B/title/Things%20Fall%20Apart"
run getbookreview    "curl -s $B/review/1"
run register         "curl -s -X POST $B/register -H 'Content-Type: application/json' -d '{\"username\":\"ifeanyi\",\"password\":\"StrongPass123\"}'"
run login            "curl -s -c cookies.txt -X POST $B/customer/login -H 'Content-Type: application/json' -d '{\"username\":\"ifeanyi\",\"password\":\"StrongPass123\"}'"
run reviewadded      "curl -s -b cookies.txt -X PUT $B/customer/auth/review/1 -H 'Content-Type: application/json' -d '{\"review\":\"This is an excellent book. I highly recommend it.\"}'"
run deletereview     "curl -s -b cookies.txt -X DELETE $B/customer/auth/review/1"
rm -f cookies.txt
echo "Done. Check the evidence/ folder."
