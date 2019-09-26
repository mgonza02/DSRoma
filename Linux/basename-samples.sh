FILE="/home/vivek/lighttpd.tar.gz"
basename "$FILE"
f="$(basename -- $FILE)"
echo "$f"

FILE2="/home/vivek/lighttpd.tar.gz"
echo ${FILE2##*/}



FILE3="/home/vivek/lighttpdz/"
echo ${FILE3##*/}
## another example ##
url="https://www.cyberciti.biz/files/mastering-vi-vim.pdf"
echo "${url##*/}"

FILE="/home/vivek/lighttpd.tar.gz"
echo "${FILE#*.}"     # print tar.gz
echo "${FILE##*.}"    # print gz
ext="${FILE#*.}"      # store output in a shell variable 
echo "$FILE has $ext" # display it