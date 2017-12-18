#!/bin/bash

echo inserisci il nome del sito

read nomesito

mkdir ./${nomesito}

cat elenco_prodotti | awk '{print $1}' > prodotti

numero_linee_prodotti="$(cat prodotti | wc -l)"

for (( meme=1; meme!=${numero_linee_prodotti} + 2; meme++ ))

do

url_prodotto=$(cat prodotti | head -${meme} | tail -1)

echo l\'url è $url_prodotto

wget  -P ./download/ $url_prodotto

#CONTINUA QUI

echo finito! rimuovo le parti sopra e sotto le thumb...

echo pagina scaricata, ottengo il titolo...

cat ./download/* | sed -n '/<title>/,/description/p' > title.html

cat title.html | sed '2d' | sed 's#<title>##' | sed 's#</title>##' | sed -e 's/ /_/g' | awk '{print $1}' > newtitle2.html

nomeprodotto=$(<newtitle2.html)

echo il nome del prodotto è "$nomeprodotto"

mkdir ./${nomesito}/${nomeprodotto}

cat ./download/* | sed -n '/<div id="thumbs_list">/,/<!-- end thumbs_list -->/p' > inizio_fine_tag.html

echo estraggo solo le linee con le immagini...

cat inizio_fine_tag.html | sed -n '/<a href/p' > immagini_con_tag.html

echo estratte solo le linee con le immagini

cat immagini_con_tag.html | sed 's/<a href="//g' > no_href.html

cat no_href.html | sed 's/data-fancybox.*title="//' > no_tag_inutili.html

cat no_tag_inutili.html | sed 's/"//' > 2_char_inutili.html

cat 2_char_inutili.html | sed 's/"//' > 1_char_inutile.html

cat 1_char_inutile.html | sed 's/>//' > final.html

echo "rimuovo i nomi e mantengo solo gli url in un nuovo file"

cat final.html | awk '{print $1}' > url_immagini.html

echo il file si chiama url_immagini.html

rm -Rf ./download 
rm inizio_fine_tag.html immagini_con_tag.html no_href.html no_tag_inutili.html 2_char_inutili.html 1_char_inutile.html

cat final.html | awk '{print $1}' > script_download.sh

lines="$(cat script_download.sh |wc -l)"

for (( i=1; i!=lines+1; i++ ))

do

n="$(cat script_download.sh |head -$i |tail -1)"

#echo "wget -P ./${nomesito}/ $n -O '${nomeprodotto}${i}.png'" >> script_download1.sh
echo "wget $n -O '${nomesito}/${nomeprodotto}/${nomeprodotto}_${i}.png'" >> script_download1.sh

done

chmod 777 script_download1.sh

./script_download1.sh

rm script_down* title.html newtitle2.html prodotti

mv final.html ./${nomesito}/final_${nomeprodotto}.html

mv url_immagini.html ./${nomesito}/url_immagini_${nomeprodotto}.html

done
