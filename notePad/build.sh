#
jsonf=_data/inkpad.json
yamlf=_data/inkpad.yml

PATH="./bin:${PATH}"
printurl='https://inkpadnotepad.appspot.com/notes/print?key=:key'

if [ ! -e $jsonf ]; then
jsonurl='https://inkpadnotepad.appspot.com/api/export?output=json&offset=-120'
# TBD : get session cookie from google (login)
sh bin/login | read $cookie
curl -L $jsonurl -H "$cookie" > $jsonf
# -H 'authority: inkpadnotepad.appspot.com'
# -H 'pragma: no-cache'
# -H 'cache-control: no-cache'
# -H 'upgrade-insecure-requests: 1'
# -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.132 Safari/537.36'
# -H 'sec-fetch-dest: document'
# -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9'
# -H 'sec-fetch-site: same-origin'
# -H 'sec-fetch-mode: navigate'
# -H 'sec-fetch-user: ?1'
# -H 'referer: https://inkpadnotepad.appspot.com/settings'
# -H 'accept-language: en-US,en;q=0.9,fr-FR;q=0.8,fr;q=0.7'
# --compressed
fi

perl -S json2yml.pl $jsonf > $yamlf

