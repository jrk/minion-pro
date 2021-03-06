#!/bin/sh
## Information
## http://carlo-hamalainen.net/blog/2007/12/11/installing-minion-pro-fonts/
## http://www.ctan.org/tex-archive/fonts/mnsymbol/

## 0.1: Install LCDF Typetools
## http://www.lcdf.org/type/
## If you use Homebrew (http://mxcl.github.com/homebrew/), then uncomment: 
# brew install lcdf-typetools 

## 0.2: If ~/tmp doesn't exist, create it.
TMP=/tmp
# mkdir ~/tmp

## Destination. System wide:  
DEST=`kpsexpand '$TEXMFLOCAL'`
## Or single-user only:
#DEST=~/Library/texmf

# Get path to script, where we might also store pfbs, etc.
SRCDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

## Downloader:
DOWNLOAD="curl -L -O"

## Directory where minion fonts can be found:
#MINIONSRC=/Applications/Adobe\ Reader.app/Contents/Resources/Resource/Font/
#MINIONSRC=~/tmp/minionsrc
MINIONSRC=~/Library/Fonts

## Everything gets done in a temporary directory
mkdir -p $TMP/minionpro
mkdir -p $DEST

function install_mnsymbol () {
  pushd $TMP

  ## 1: MnSymbol
  ## http://www.ctan.org/tex-archive/fonts/mnsymbol/
  $DOWNLOAD http://mirror.ctan.org/fonts/mnsymbol.zip 

  unzip mnsymbol
  cd mnsymbol/tex

  ## Generates MnSymbol.sty
  latex MnSymbol.ins

  mkdir -p $DEST/tex/latex/MnSymbol/      \
      $DEST/fonts/source/public/MnSymbol/ \
      $DEST/doc/latex/MnSymbol/

  cp MnSymbol.sty $DEST/tex/latex/MnSymbol/MnSymbol.sty
  cd .. # we were in mnsymbol/tex
  cp source/* $DEST/fonts/source/public/MnSymbol/
  cp MnSymbol.pdf README $DEST/doc/latex/MnSymbol/

  mkdir -p $DEST/fonts/map/dvips/MnSymbol \
      $DEST/fonts/enc/dvips/MnSymbol      \
      $DEST/fonts/type1/public/MnSymbol   \
      $DEST/fonts/tfm/public/MnSymbol 
  cp enc/MnSymbol.map $DEST/fonts/map/dvips/MnSymbol/
  cp enc/*.enc $DEST/fonts/enc/dvips/MnSymbol/
  cp pfb/*.pfb $DEST/fonts/type1/public/MnSymbol/
  cp tfm/* $DEST/fonts/tfm/public/MnSymbol/

  ## I believe that this is not strictly needed if DEST is in the home
  ## tree on OSX, but might be needed otherwise
  sudo mktexlsr
  sudo updmap-sys --enable MixedMap MnSymbol.map
  
  popd
}

function test_mnsymbol () {
  pushd $TMP
  
  cp $SRCDIR/mnsymbol-test.tex .
  pdflatex mnsymbol-test.tex
  open mnsymbol-test.pdf
  
  popd
}


function setup_minionpro () {
  ## 2: MinionPro
  mkdir -p $TMP/minionpro
  pushd $TMP/minionpro

  $DOWNLOAD http://mirrors.ctan.org/fonts/minionpro/enc-2.000.zip
  $DOWNLOAD http://mirrors.ctan.org/fonts/minionpro/metrics-base.zip
  $DOWNLOAD http://mirrors.ctan.org/fonts/minionpro/metrics-full.zip
  $DOWNLOAD http://mirrors.ctan.org/fonts/minionpro/metrics-opticals.zip
  $DOWNLOAD http://mirrors.ctan.org/fonts/minionpro/scripts.zip
  
  popd
}

function convert_minionpro_otf () {
  pushd $TMP/minionpro

  ## This will make the otf directory, among other things.
  unzip scripts.zip

  cp $MINIONSRC/Minion*otf otf/

  ## Generate the pfb files
  ## This step requires that the LCDF type tools are installed.  Get them here:
  ##   http://www.lcdf.org/type/
  ./convert.sh

  popd
}

function copy_minionpro_pfb () {
  pushd $TMP/minionpro
  
  rsync -av $SRCDIR/pfb ./
  
  popd
}


function install_minionpro () {
  pushd $TMP/minionpro
  
  ## Copy the pfb files to where they belong:
  mkdir -p $DEST/fonts/type1/adobe/MinionPro
  cp pfb/*.pfb $DEST/fonts/type1/adobe/MinionPro

  SRC=`pwd`
  cd $DEST
  unzip $SRC/enc-2.000.zip
  unzip $SRC/metrics-base.zip
  unzip $SRC/metrics-full.zip
  unzip $SRC/metrics-opticals.zip
  cd $SRC

  sudo mktexlsr
  updmap --enable MixedMap MinionPro.map

  popd
}

function test_minionpro () {
  pushd $TMP
  
  ## Test:
  cp $SRCDIR/minionpro-test.tex .
  pdflatex minionpro-test.tex
  open minionpro-test.pdf
  
  popd
}

test_mnsymbol

setup_minionpro
copy_minionpro_pfb
install_minionpro
test_minionpro
