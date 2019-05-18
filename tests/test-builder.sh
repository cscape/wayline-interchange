node node-build.js | while read p; do
  echo "Agency $p name is" $(node GetAgency.js -id=$p -get=name)
done