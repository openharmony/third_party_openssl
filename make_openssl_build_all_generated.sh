#!/usr/bin/env bash
# Copyright (c) 2023 Huawei Device Co., Ltd.
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

set -e
pwd # out/target_name
openssl_source_path="$1"
build_all_generated_path="$2"
openssl_selected_platform="$3"
rm -rf ${build_all_generated_path}/${openssl_selected_platform}
mkdir -p ${build_all_generated_path}
pushd ${build_all_generated_path}
    rm -rf ./openssl
    cp -r ${openssl_source_path} openssl
    pushd openssl
        ./Configure ${openssl_selected_platform}
        make build_all_generated -j256 >/dev/null 2>&1
    popd
    diff -q -r --exclude=".git" ${openssl_source_path} openssl | sed 's#^Only in ##;s#: #/#' | tar -czf ${openssl_selected_platform}.tgz -T -
    rm -rf ./openssl
    tar -xf ${openssl_selected_platform}.tgz
    mv openssl ${openssl_selected_platform}
    rm -f ${openssl_selected_platform}.tgz
popd
