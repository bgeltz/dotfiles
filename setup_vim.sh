#!/bin/bash
#
# Copyright 2018 Brad Geltz
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

if [ -d "vim/.vim/autoload" ]; then
    echo "vim/.vim/autoload already exists!  Exitting..."
    exit 1
fi

if [ ! -x "$(command -v stow)" ]; then
    echo "Command \"stow\" not available.  Exitting..."
    exit 1
fi

mkdir -p vim/.vim/autoload
pushd vim/.vim/autoload
curl -LSso pathogen.vim https://tpo.pe/pathogen.vim
popd

mkdir -p vim/.vim/bundle
pushd vim/.vim/bundle
git clone https://github.com/scrooloose/nerdcommenter.git
git clone https://github.com/luochen1990/rainbow.git
git clone https://github.com/bgeltz/vim-fugitive.git
git clone https://github.com/airblade/vim-gitgutter.git
popd

stow vim
vim -u NONE -c "helptags vim-fugitive/doc" -c q
