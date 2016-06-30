: 'Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
'

#!/bin/bash

programname=$0
echo $#

function usage {
    echo "usage: $programname [-l lang] [-path tesseract_path]"
    echo "	-l,--lang			language"
    echo "  -path               path to tesseract bin directory"
    exit 1
}

if [[ "$#" < 4 ]]; then
    usage
fi

# parse arguments
while [[ $# > 1 ]]
do
key="$1"

case $key in
    -num|--num_imgs)
    NUM_IMGS="$2"
    shift # past argument
    ;;
    -l|--lang)
    LANG="$2"
    shift # past argument
    ;;
    -f|--font)
    FONT="$2"
    shift # past argument
    ;;
    -path)
    # set path to tesseract bin directory
    # /usr/local/Cellar/tesseract/3.04.01_1/bin
    TESSERACT="$2"
    shift # past argument
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

ls -a | grep -i tif | cut -d "." -f 1  > files.txt
filename=files.txt

# check if input files exist
while read -r line
do
    if [[ ! -e $line".tif" ]]; then
        echo "$file.tif does not exist. Exiting now."            
        exit 1
    fi
done < "$filename"

# create box files
while read -r line
do
    echo $TESSERACT/tesseract
    $TESSERACT/tesseract $line.tif $line batch.nochop makebox
    if [ "$?" != 0 ]; then
        echo "Error during creating box files. Exiting now."
        exit 1
    fi
done < "$filename"

#correcting the box files

# feed box files to tesseract
while read -r line
do
    $TESSERACT/tesseract $line.tif $line.box nobatch box.train.stderr
    if [ "$?" != 0 ]; then
        echo "Error during processing box files. Exiting now."
        exit 1
    fi
done < "$filename"

# extract unicharset
$TESSERACT/unicharset_extractor *.box
echo "$?"
if [ "$?" != 0 ]; then
    echo "Error during extracting unicharset. Exiting now."
    exit 1
fi

# create shapetable
$TESSERACT/shapeclustering -F font_properties -U unicharset *.tr
echo "$?"
if [ "$?" != 0 ]; then
    echo "Error while creating shapetable. Exiting now."
    exit 1
fi

# create training data
$TESSERACT/mftraining -F font_properties -U unicharset -O $LANG.unicharset *.tr
echo "$?"
if [ "$?" != 0 ]; then
    echo "Error while creating training data. Exiting now."
    exit 1
fi
$TESSERACT/cntraining *.tr
echo "$?"
if [ "$?" != 0 ]; then
    echo "Error while creating training data. Exiting now."
    exit 1
fi

# generate dawg files from corresponding word lists
$TESSERACT/wordlist2dawg words_list $LANG.word-dawg $LANG.unicharset
echo "$?"
if [ "$?" != 0 ]; then
    echo "Error while creating word-dawg data. Exiting now."
    exit 1
fi

$TESSERACT/wordlist2dawg frequent_words_list $LANG.freq-dawg $LANG.unicharset
echo "$?"
if [ "$?" != 0 ]; then
    echo "Error while creating freq-dawg data. Exiting now."
    exit 1
fi

# rename files before combining them
mv normproto $LANG.normproto
mv inttemp $LANG.inttemp
mv pffmtable $LANG.pffmtable
mv shapetable $LANG.shapetable
mv unicharset $LANG.unicharset

# combine all files to generate traineddata
$TESSERACT/combine_tessdata $LANG.
if [ "$?" != 0 ]; then
    echo "Error while combining training data. Exiting now."
    exit 1
fi

rm $filename

# move traineddata to tessdata directory
sudo mv $LANG.traineddata /usr/local/share/tessdata