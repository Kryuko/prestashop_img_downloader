#!/bin/bash

#file di test usato per i log

#echo Ciao $USER ! Inserisci l\'URL del sito da scaricare, includendo HTTP o HTTPS.

#read sito

#echo inserisci il nome del sito

#read nomesito

echo log o senza log\?

echo 1. Log attivi

echo 2. Log disattivati

read active_log

echo 1. Opzione Log 2 >> log.txt

cat elenco_prodotti | awk '{print $1}' > prodotti

numero_linee_prodotti="$(cat prodotti | wc -l)"

for (( meme=1; meme!=${numero_linee_prodotti} + 2; meme++ ))

do

url_prodotto=$(cat prodotti | head -${meme} | tail -1)

nomesito=$(cat ${url_prodotto} | tr '/' ' ' | awk '{print $2}')

echo 2. l\'url è $url_prodotto >> log.txt

echo 3. Il nome del sito è $nomesito >> log.txt

mkdir ./${nomesito}

wget  -P ./download/ $url_prodotto

echo 4. Finito! rimuovo le parti sopra e sotto le thumb... >> log.txt

echo 5. Pagina scaricata, ottengo il titolo... >> log.txt

cat ./download/* | sed -n '/<title>/,/description/p' > title.html

cat title.html | sed '2d' | sed 's#<title>##' | sed 's#</title>##' | sed -e 's/ /_/g' | awk '{print $1}' > newtitle2.html

nomeprodotto=$(<newtitle2.html)

echo 6. Il nome del prodotto è "$nomeprodotto" >> log.txt

mkdir ./${nomesito}/${nomeprodotto}

cat ./download/* | sed -n '/<div id="thumbs_list">/,/<!-- end thumbs_list -->/p' > inizio_fine_tag.html

echo 7. Estraggo solo le linee con le immagini... >> log.txt

cat inizio_fine_tag.html | sed -n '/<a href/p' > immagini_con_tag.html

echo 8. Estratte solo le linee con le immagini >> log.txt

cat immagini_con_tag.html | sed 's/<a href="//g' > no_href.html

cat no_href.html | sed 's/data-fancybox.*title="//' > no_tag_inutili.html

cat no_tag_inutili.html | sed 's/"//' > 2_char_inutili.html

cat 2_char_inutili.html | sed 's/"//' > 1_char_inutile.html

cat 1_char_inutile.html | sed 's/>//' > final.html

if [ "$active_log" == "2" ]; then
	rm inizio_fine_tag.html immagini_con_tag.html no_href.html no_tag_inutili.html 2_char_inutili.html 1_char_inutile.html
	echo 9. Elementi rimossi >> log.txt
fi

#echo "rimuovo i nomi e mantengo solo gli url in un nuovo file"

cat final.html | awk '{print $1}' > url_immagini.html

echo 10. Il 'file' si chiama url_immagini.html >> log.txt

#rm -Rf ./download 

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

if [ "$active_log" == "2" ]; then
	rm script_down* title.html newtitle2.html prodotti
fi

mv final.html ./${nomesito}/final_${nomeprodotto}.html

mv url_immagini.html ./${nomesito}/url_immagini_${nomeprodotto}.html

done
