:'Licensed to the Apache Software Foundation (ASF) under one
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

# set path to tesseract bin directory
TESSERACT=/usr/local/Cellar/tesseract/3.04.01_1/bin

programname=$0

function usage {
    echo "usage: $programname [-num num_images] [-l lang] [-f font]"
    echo "	-num,--num_images	number of images"
    echo "	-l,--lang			language"
    echo "	-f,--font 			font"
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
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

echo NUMBER OF IMAGES = "${NUM_IMGS}"
echo LANGUAGE = "${LANG}"
echo FONT = "${FONT}"

# check if input files exist
for i in $(seq 1 $NUM_IMGS);
    do
        if [[ ! -e "$LANG.$FONT.exp$i.tif" ]]; then
            echo "$LANG.$FONT.exp$i.tif does not exist. Exiting now."
            exit 1
        fi
        if [[ ! -e "$LANG.$FONTb.exp$i.tif" ]]; then
            echo "$LANG.$FONT.exp$i.tif does not exist. Exiting now."
            exit 1
        fi
done

# create box files
for i in $(seq 1 $NUM_IMGS);
	do
		$TESSERACT/tesseract $LANG.$FONT.exp$i.tif $LANG.$FONT.exp$i batch.nochop makebox
        if [ "$?" == 1 ]; then
            echo "Error during creating box files. Exiting now."
            exit 1
        fi
        $TESSERACT/tesseract $LANG.$FONTb.exp$i.tif $LANG.$FONTb.exp$i batch.nochop makebox
        if [ "$?" == 1 ]; then
            echo "Error during creating box files. Exiting now."
            exit 1
        fi
done

#correcting the box files

# feed box files to tesseract
for i in $(seq 1 $NUM_IMGS);
	do
		$TESSERACT/tesseract $LANG.$FONT.exp$i.tif $LANG.$FONT.exp$i.box nobatch box.train.stderr
        if [ "$?" == 1 ]; then
            echo "Error during processing box files. Exiting now."
            exit 1
        fi
        $TESSERACT/tesseract $LANG.$FONTb.exp$i.tif $LANG.$FONTb.exp$i.box nobatch box.train.stderr
        if [ "$?" == 1 ]; then
            echo "Error during processing box files. Exiting now."
            exit 1
        fi
done

# extract unicharset
$TESSERACT/unicharset_extractor *.box
if [ "$?" == 1 ]; then
    echo "Error during extracting unicharset. Exiting now."
    exit 1
fi

# create shapetable
$TESSERACT/shapeclustering -F font_properties -U unicharset *.tr
if [ "$?" == 1 ]; then
    echo "Error while creating shapetable. Exiting now."
    exit 1
fi

# create training data
$TESSERACT/mftraining -F font_properties -U unicharset -O $LANG.unicharset *.tr
if [ "$?" == 1 ]; then
    echo "Error while creating training data. Exiting now."
    exit 1
fi
$TESSERACT/cntraining *.tr
if [ "$?" == 1 ]; then
    echo "Error while creating training data. Exiting now."
    exit 1
fi

# generate dawg files from corresponding word lists
$TESSERACT/wordlist2dawg words_list $LANG.word-dawg $LANG.unicharset
if [ "$?" == 1 ]; then
    echo "Error while creating word-dawg. Exiting now."
    exit 1
fi

$TESSERACT/wordlist2dawg frequent_words_list $LANG.freq-dawg $LANG.unicharset
if [ "$?" == 1 ]; then
    echo "Error while creating freq-dawg data. Exiting now."
    exit 1
fi


# rename files before combining them
mv normproto $LANG.normproto
mv inttemp $LANG.inttemp
mv pffmtable $LANG.pffmtable
mv shapetable $LANG.shapetable
mv unicharset $LANG.unicharset
#mv word-dawg $LANG.word-dawg
#mv freq-dawg $LANG.freq-dawg

# combine all files to generate traineddata
$TESSERACT/combine_tessdata $LANG.
if [ "$?" == 1 ]; then
    echo "Error while combining training data. Exiting now."
    exit 1
fi

# move traineddata to tessdata directory
sudo mv $LANG.traineddata /usr/local/share/tessdata