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
        # https://github.com/openssl/openssl/issues/20112#issuecomment-1400388204
        # no-shared will disable building shared libcrypto and libssl libraries.
        # But the legacy provider would still be built as a shared module.
        # So you would need the legacy shared module present on the installed
        # system and the paths would have to be correct.
        # You can use no-module to make the legacy provider built-in.

        # https://github.com/openssl/openssl/issues/17679#issue-1130060263
        # Is there a way to build a static version of openssl3, including the "legacy" OSSL_PROVIDER?
        # https://github.com/openssl/openssl/issues/17679#issuecomment-1034949099
        # Configure with no-shared no-module. The legacy provider is then part of libcrypto.a.
        # You still need to "load" it via OSSL_PROVIDER_load() - but no .so file is required in that case.

        # https://github.com/openssl/openssl/issues/19368#issuecomment-1274558844
        # no-shared affects the building of libcrypto*.dll and libssl*.dll,
        # not dynamically loadable modules (which are governed by the configuration option no-module / enable-module,
        # which is enabled by default).
        configure_cmd="./Configure ${openssl_selected_platform} no-shared no-module"
        echo $configure_cmd
        $configure_cmd
        make build_all_generated -j256 >/dev/null 2>&1
    popd
    # https://stackoverflow.com/questions/11325123/how-to-compare-two-directories-using-diff-while-ignoring-non-existing-files
    LC_ALL=C diff -q -r --exclude=".git" ${openssl_source_path} openssl | sed 's#^Only in ##;s#: #/#' | tar -czf ${openssl_selected_platform}.tgz -T -
    rm -rf ./openssl
    tar -xf ${openssl_selected_platform}.tgz
    mv openssl ${openssl_selected_platform}
    rm -f ${openssl_selected_platform}.tgz
popd
